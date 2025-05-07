import com.pdplusplus.*;

/*
This is the jet engine example from Andy Farnell's book "Designing Sound".
X-axis = speed
See the EngineGenerator class for more details.  
*/

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
   double s = map(mouseX, 0, width, 0, 1);
   music.setSpeed(s);
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
   
   double speed = 0;
   EngineGenerator jet = new EngineGenerator();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = jet.perform();   
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setSpeed(double s) {
     jet.setSpeed(s);
   }
 
   
   //Free all objects created from Pd4P3 lib
   void free() {
     jet.free();
     
   }
   
 }
