import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
  final int fftWindowSize = 2048;
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
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = 0; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFloat(float f1) {
     dummy = f1;
   }
   
   synchronized float getFloat() {
     return dummy;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     
     
   }
   
 }
