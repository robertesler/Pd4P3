import com.pdplusplus.*;

/*
This sketch demonstrates pitched and unpitched signal separation.
Use the X/Y to hear the "clean" vs "dirty" signal of the sample.
*/

 Pd pd;
 MyMusic music;
 
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   pd.setFFTWindow(2048);
   //You can use Processing's data path which is ./data/filename.wav or whatever.  Or see FileNameHelper example
   String path = this.dataPath("");
   //format this for your OS, / for Unix, \\ for Win
   path = path + "\\voice.wav";
   music.setSoundFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  background(255);
  fill(0);
  float t = map(mouseX, 0, width, 0, 20);
  music.setTime(t);
  
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
   
   synchronized void setTime(double t) {
      analysis.setTime(t); 
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
