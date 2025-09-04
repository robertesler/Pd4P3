import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float dummyFloat = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    float f = map(mouseX, 0, width, 0, 25);
    music.setFloat(f);
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
   
   float dummy = 0;
   RollGen roller = new RollGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double out = roller.perform(getFloat());
     //println(out);
     outputL = outputR = out; 
    
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFloat(float f1) {
     dummy = (f1/100);
     dummy = dummy * dummy;
   }
   
   synchronized float getFloat() {
     return dummy;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     roller.free();
     
   }
   
 }
