/*
  This sketch shows how to smooth a parameter
  such as amplitude of a sine wave. 
  This method could be used for any audio parameter that
  needs smoothing or avoid audible clicks in the audio.
  Use the mouseX to change the amplitude of the sine wave.
*/

import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  float amp1 = map(mouseX, 0, width, 0, 1.0);
  music.setAmp(amp1);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   The audio process.  This plays a sine wave and adjusts its volume.
 */
 class MyMusic extends PdAlgorithm {
   
   Oscillator osc = new Oscillator();
   float amp = 0;
   float smooth = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     outputL = outputR = osc.perform(200) * getAmp(); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setAmp(float a) {
     amp = a;
   }
   
   //This method will also smooth the amplitude to avoid clicks
   synchronized float getAmp() {
     smooth = smooth - .004 * (smooth - amp);
     return smooth;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc);
     
   }
   
 }
