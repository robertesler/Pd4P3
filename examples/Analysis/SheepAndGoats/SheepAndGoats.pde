import com.pdplusplus.*;

/*
This sketch demonstrates pitched and unpitched signal separation.
Use the X/Y to hear the "clean" vs "dirty" signal of the sample.

This sketch is pretty processor intensive.  Depending on your system
it may take a few seconds for the JVM to optimize and hear undistorted 
sound.
*/

 Pd pd;
 MyMusic music;
 final int fftWindowSize = 2048;
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   //make sure to set the FFT window size in Pd4P3
   pd.setFFTWindow(fftWindowSize);
   //You can use Processing's data path which is ./data/filename.wav or whatever.  Or see FileNameHelper example
   String path = this.dataPath("voice.wav");
   music.setSoundFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  background(255);
  fill(0);
  float d = map(mouseX, 0, width, 80, 100);
  float c = map(mouseY, 0, height, 30, 0);
  String s = "clean: " + str(c) + ", dirty: " + str(d);
  text(s, (width/2)-80, 20);
  music.setClean(c);
  music.setDirty(d);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This class will analyze the signal and test whether the signal is 
   "clean" or the coherent, or "dirty" or incoherent.  This will determine
   which bins are pitch and which are noise.  Then we can balance between each
   and remove one or the other. 
 */
 class MyMusic extends PdAlgorithm {
   
   Analysis analysis = new Analysis();
   SoundFiler soundfiler = new SoundFiler();
   double[] wav;
   int counter = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     if(counter == wav.length) counter = 0;
     double out = analysis.perform(wav[counter++]);
     outputL = outputR = out; 
     
   }
   
   synchronized void setDirty(double d) {
      analysis.setDirty(d); 
   }
   
   synchronized void setClean(double c) {
      analysis.setClean(c);
   }
   
   void setSoundFile(String f) {
       double s = soundfiler.read(f);
       wav = new double[(int)s];
       wav = soundfiler.getArray();
      
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(soundfiler);
     analysis.free();
     
   }
   
 }
