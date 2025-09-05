import com.pdplusplus.*;

/*
A simulation of a can (or resonant cylinder) rolling.
This is inspired by Andy Farnell's example from "Designing Sound"

The X axis controls the speed of the simulation (via the amplitude of 
the phasor).

The Y axis controls the irregularity of the simulation (via the frequency
of the phasor).  

See RollGen class for more details.

*/


 Pd pd;
 MyMusic music;
 
 float dummyFloat = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   pd.start();
   
 }
 
 void draw() {
    float a = map(mouseX, 0, width, 0, 25);
    music.setAmp(a);
    float f = map(mouseY, height, 0, .1, 1);
    music.setFreq(f);
    
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 

 class MyMusic extends PdAlgorithm {
   
   double amp = 0;
   double freq = .5;
   RollGen roller = new RollGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double out = roller.perform(getAmp(), getFreq());
     //println(out);
     outputL = outputR = out; 
    
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setAmp(double a) {
     amp = (a/100);
     amp = amp * amp;
   }
   
   synchronized double getAmp() {
     return amp;
   }
   
   synchronized void setFreq(double f) {
      freq = f; 
   }
   
   synchronized double getFreq() {
      return freq; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     roller.free();
     
   }
   
 }
