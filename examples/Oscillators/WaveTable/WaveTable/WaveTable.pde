import com.pdplusplus.*;
import com.portaudio.*;

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
   
   TabRead4 tab4 = new TabRead4();
   float freq = 0;
   int tableSize = 128;
   double[] table = new double[tableSize+4];//extra points for interpolation
   
   public void MyMusic() {
     
     //make a square wave table
     for(int i = 0; i < tableSize+3; i++)
     {
         if(i > tableSize/2)
           table[i] = 1;
           else
             table[i] = 0;
     }
     tab4.setTable(table);
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = 0; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
     notify();//this tells audio thread something has happened.
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     TabRead4.free(tab4);
     
   }
   
 }
