import com.pdplusplus.*;

/*
This is a basic water generator inspired by Andy Farnell's
book "Designing Sound". 
X = rate
Y = volume
*/

 Pd pd;
 MyMusic music;
 
 float gain = 1;
 float rate = 1;
 
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  rate = map(mouseX, 0, width, 1, .5);
  music.setRate(rate);
 
  gain = map(mouseY, height, 0, 1, 3);
  music.setGain(gain);
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
   
   float gain = 1;
   float rate = 1;
   WaterGen water1 = new WaterGen();
   WaterGen water2 = new WaterGen();
   WaterGen water3 = new WaterGen();
   WaterGen water4 = new WaterGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double w1 = water1.perform(8 * getRate(), 4000, 150, 2.689);
     double w2 = water2.perform(11 * getRate(), 5000, 100, 2.1);
     double w3 = water3.perform(5 * getRate(), 2000, 100, 1.897);
     double w4 = water4.perform(13 * getRate(), 6000, 180, 3);
     outputL = (w1 + w2) * getGain();
     outputR = (w3 + w4) * getGain(); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setGain(float f1) {
     gain = f1;
   }
   
   synchronized float getGain() {
     return gain;
   }
   
   synchronized void setRate(float r) {
     rate = r;
   }
   
   synchronized float getRate() {
      return rate; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     water1.free();
     water2.free();
     water3.free();
     water4.free();
     
   }
   
 }
