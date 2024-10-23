import com.pdplusplus.*;

/*
This is a basic old-school sampler example
It takes a sample and buffers it in RAM
Then will alter the playback rate via TabRead4
to transpose the pitch according to the X-axis (MIDI Note #)

It is based around the same concept as Pd's help patch
D10.sampler.notes.pd
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float note = 60;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
    String path = this.dataPath("C3.wav");
    music.loadAudioFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    note = map(mouseX, 0, width, 48, 72); //MIDI note numbers for 2 octaves)
 }
 
 void mousePressed() {
    music.setNote(note); 
    music.setBang(true);
    println("mouse");
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   Line line = new Line();
   Line line2 = new Line();
   TabRead4 tabread = new TabRead4();
   SoundFiler soundfiler = new SoundFiler();
   double[] sample;
   int sampleSize = 0;
   float note = 60;
   float lineTime = 1e+07;
   final float rampTime = 4.41e+08;
   float lineTarget = 0;
   boolean bang = false;
   float attack = 5;
   float release = 100;
   double env = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double index = line.perform(getRampTime(getNote()), lineTime);
     outputL = outputR = tabread.perform(index) * env; 
     
     //This is a second envelope to control the amplitude of our playback.
     if(getBang())
     {
       env = line2.perform(1, attack);  
     }
     else
     {
       env = line2.perform(0, (sampleSize/this.getSampleRate())*1000); 
     }
     
     if(env == 1)
     {
       bang = false;
     }
     
   }
  
  //Load our audio file into RAM
   public void loadAudioFile(String f) {
     sampleSize = (int)soundfiler.read(f); 
     sample = new double[sampleSize+4];
     sample = soundfiler.getArray();
     tabread.setTable(sample);

  }
  
  //We use synchronized to communicate with the audio thread
  //Stop the line, reset and set the new Note
   synchronized void setNote(float f1) {
     line.stop();
     line.perform(0,0);
     note = f1;
   }
   
   synchronized float getNote() {
     return note;
   }
   
   //Ramp time is calculated based on 1000 * SR, mtof(note)/261.6
   synchronized double getRampTime(double note) {
     return rampTime * (this.mtof(note) / 261.6);
   }
   
   synchronized void setBang(boolean b) {
     bang = b;
   }
   
  synchronized boolean getBang() { 
     return bang;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Line.free(line);
     Line.free(line2);
     TabRead4.free(tabread);
     SoundFiler.free(soundfiler);
     
   }
   
 }
