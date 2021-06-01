import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float delTime = 1000;//milliseconds

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   music.setTime(delTime);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
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
   
   Delay del = new Delay();
   float dummy = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     //Just be careful, use headphones, input is routed to output!
     outputL = outputR = del.perform( (in1 + in2) * .5); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setTime(float t) {
     del.setDelayTime(t);
   }
   
   synchronized float getFloat() {
     return dummy;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Delay.free(del);
     
   }
   
 }
