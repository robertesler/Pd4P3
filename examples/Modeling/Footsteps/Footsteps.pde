import com.pdplusplus.*;

/*
  This is a footstep generator.  It is inspired and based on 
  Andy Farnell's example from his book "Designing Sound."
  X = speed.
*/
 Pd pd;
 MyMusic music;
 
 float speed = 0;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  speed = map(mouseX, 0, width, 0, .4);
  music.setSpeed(speed);
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
   
   Foot foot = new Foot();
   float speed = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = foot.perform(getSpeed(), 0); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setSpeed(float s) {
     speed = s;
   }
   
   synchronized float getSpeed() {
     return speed;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     foot.free();
     
   }
   
 }
