import com.pdplusplus.*;

/*
This is a fire simluation inspired by Andy Farnell's 
"Designing Sound". 

It uses one noise generator to synchronized three basic
components: crackles, hissing and lapping.  
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
   
   FireGen fire1 = new FireGen();
   FireGen fire2 = new FireGen();
   FireGen fire3 = new FireGen();
   FireGen fire4 = new FireGen();
   BandPass bp1 = new BandPass();
   BandPass bp2 = new BandPass();
   BandPass bp3 = new BandPass();
   HighPass hip = new HighPass();

   public MyMusic() {
     bp1.setCenterFrequency(600);
     bp1.setQ(0.2);
     
     bp2.setCenterFrequency(1200);
     bp2.setQ(0.7);
     
     bp3.setCenterFrequency(2600);
     bp3.setQ(0.4);
     
     hip.setCutoff(1000);
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
 
     double fire = bp1.perform(fire1.perform()) + bp2.perform(fire2.perform()) +
     bp3.perform(fire3.perform()) + hip.perform(fire4.perform()) ;

     outputL = outputR = fire * .3; 
     
   }
  
   //Free all objects created from Pd4P3 lib
   void free() {
     fire1.free();
     fire2.free();
     fire3.free();
     fire4.free();
     BandPass.free(bp1);
     BandPass.free(bp2);
     BandPass.free(bp3);
     HighPass.free(hip);
   }
   
 }
