import com.pdplusplus.*;

/*
An emulation of a cricket, thanks to Andy Farnell's model
in "Designing Sound."
X = rate
Y = volume
*/
 Pd pd;
 MyMusic music;
 
 float rate = 1.43;
 float gain = 1.0;
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   rate = map(mouseX, 0, width, 1, 2);
   music.setRate(rate);
   gain = map(mouseY, height, 0, .2, 1);
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
   
   float rate = 1.43;
   float gain = 1;
   CricketGen cricket = new CricketGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = cricket.perform(getRate()) * getGain(); 
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setRate(float f1) {
     rate = f1;
   }
   
   synchronized float getRate() {
     return rate;
   }
   
   synchronized void setGain(float f1) {
     gain = f1;
   }
   
   synchronized float getGain() {
     return gain;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     cricket.free();
     
   }
   
 }
