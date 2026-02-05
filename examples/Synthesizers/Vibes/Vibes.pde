import com.pdplusplus.*;

/*
Here we have an additive synthesizer that simulates the
harmonics and decay of a vibraphone, or marimba.

The X-axis is frequency
Click the mouse to hear the attack.

*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq = 200;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    freq = map(mouseX, 0, width, 200, 600);
 }
 
 void mousePressed() {
    music.setFreq(freq);
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
   
   float freq = 0;
   VibeGen vibes = new VibeGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = vibes.perform(getFreq()); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f) {
     freq = f;
     vibes.setAttack();
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     vibes.free();
   }
   
 }
