import com.pdplusplus.*;

/*
This is an example of phase vocoder. It is an implementation of Miller Puckette's
from Pure Data, see example I07 in Pd. 
It can both stretch the time w/o changing the pitch and
the pitch w/o changing the length.  

The X-axis is the pitch
The Y-axis is the time
Click the mouse to rewind the sample.
*/

//declare Pd and create new class that inherits PdAlgorithm
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
   music.loadSample(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
   fill(0);
   float t = map(mouseX, 0, width, -150, 150);
   music.setTranspo(t);
   float s = map(mouseY, height, 0, 20, 200);
   music.setSpeed(s);
 }
 
 void mousePressed() {
    music.rewind();
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
   
   float speed = 0;
   PhaseVocoder pvoc = new PhaseVocoder();
   
   public MyMusic() {
     //This phase locks our two windows.  See the code for more info.
       pvoc.setLock(1);
   }
   
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = pvoc.perform(); 
   }
  
  //Speed is our time shift
   synchronized void setSpeed(float s) {
     pvoc.setSpeed(s);
   }
   
   //Transpo, or transposition, is our pitch shift
   synchronized void setTranspo(double t) {
     pvoc.setTranspo(t); 
   }
   
   //rewind to play the sample from the beginning
   synchronized void rewind() {
     pvoc.setRewind();
   }
  
  //phase lock
   synchronized void lock(int l) {
      pvoc.setLock(l); 
   }
   
   //do this first please, loads our audio file
   void loadSample(String f) {
      pvoc.inSample(f); 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     PhaseVocoder.free(pvoc); 
   }
   
 }
