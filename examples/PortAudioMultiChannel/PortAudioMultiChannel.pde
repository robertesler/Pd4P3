import com.pdplusplus.*;
import com.portaudio.*;

//Open our Native Library
  static {
    /*
     * This is the pd++ lib
     * */
    System.loadLibrary("pdplusplus");
    System.out.println("Loading pd++ library");
  }

//declare Pd and create new class that inherits PdAlgorithm
 PaMulti pd;
 Music music;
 
 float dummyFloat = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new Music();
   pd = new PaMulti(4);
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
 class Music extends PdMaster {
   
   float dummy = 0;
   Oscillator osc = new Oscillator();
   Oscillator osc2 = new Oscillator();
   double output1 = 0;
   double output2 = 0;
   double output3 = 0;
   double output4 = 0;
 
   //All DSP code goes here
   void runAlgorithm(double in1, double in2, double in3, double in4) {
     output1 = output2 = osc2.perform(330) * .5;
     output3 = output4 = osc.perform(220) *.5; 
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
     Oscillator.free(osc);
     Oscillator.free(osc2);
   }
   
 }
