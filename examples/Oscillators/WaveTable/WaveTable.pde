import com.pdplusplus.*;
import com.portaudio.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq = 200;
 float q = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   music.setTable();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  freq = map(mouseX, 0, width, 200.0, 800.0);
  q = map(mouseY, 0, height, 30, .2);
   music.setFreq(freq);
   music.setQ(q);
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
   Phasor phasor = new Phasor();
   VoltageControlFilter vcf = new VoltageControlFilter();
   float freq = 0;
   float q = 1;
   int tableSize = 128;
   float amplitude = .5f;
   double[] table = new double[tableSize+4];//extra points for interpolation
   
   //make a square wave table
   public void setTable() {
     
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
     
     //Since tabread4 is 4-point interpolation we need to start our loop at 1 and end at
     double loop = phasor.perform( getFreq() ) * ( table.length-2 ) + 1;
     //filter the wavetable
     vcf.setQ(getQ());
     double out[] = vcf.perform( tab4.perform(loop), getFreq() ) ;
     outputL = outputR = out[1] * amplitude;
     
   }
 
  /*
    Getters and Setters
  */
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   synchronized void setQ(float c) {
     q = c;
   }
   
   synchronized float getQ() {
     return q;
   }

   /******* Free all objects created from Pd4P3 lib *****/
   void free() {
     TabRead4.free(tab4);
     Phasor.free(phasor);
     VoltageControlFilter.free(vcf);
   }
   
 }
