import com.pdplusplus.*;

/*
This example shows how to use a 3rd-order Butterworth filter.
A Butterworth Filter is a flat response filter that can be
configured as a low pass, high pass or shelving filter.  

They are most commonly used in amplifiers, crossovers, 
anti-aliasing, data smoothing or anywhere else you would 
want smooth, flat 18dB per octave filter slopes.  

I would avoid reading the Butterworth Filter wikipedia page
if you are having trouble understanding how this is different from
a basic low pass.  

Instead, click on the window at runtime and you can hear the 
difference.

*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 int compare = 0;

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    float f = map(mouseX, 0, width, 250, 1000);
    music.setFreq(f);
    background(0);
    textSize(20);
    text("Click to compare", 10, 40);
    
    textSize(36);
    if(compare == 1)
      text("1st order low pass", width/3.5, height/2);
    else
      text("Butterworth Filter", width/3.5, height/2);
 }
 
 void mousePressed() {
    compare++;
    compare %= 2;
    
    if(compare == 1)
      music.setCompare(true); 
    else
      music.setCompare(false); 
           
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   We test our filter with noise
 */
 class MyMusic extends PdAlgorithm {
   
   float freq = 0;
   Noise noise = new Noise();
   LowPass lop = new LowPass();
   Butterworth butterworth = new Butterworth(830.6, 47359.3, 0, 1);
   
   boolean compare = false;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     if(!compare)
     {
       outputL = outputR = butterworth.perform(noise.perform()); 
     }
     else
     {
       outputL = outputR = lop.perform(noise.perform());
     }
     
     
   }
   
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f) {
     freq = f;
     if(!compare)
       butterworth.setLowPass(f, 0);
     else
       lop.setCutoff(f);
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   synchronized void setCompare(boolean b)  {
      compare = b; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     butterworth.free();
     
   }
   
 }
