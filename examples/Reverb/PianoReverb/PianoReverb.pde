import com.pdplusplus.*;

/*
This sketch is a phase vocoder reverberator example.  It is adapted from
Pure Data's pvoc.reverb or "Piano Reverb" example.  

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
   This class will play a sample and pass it through our reverberator.
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
