import com.pdplusplus.*;

/*
This sketch shows how you can oversample a signal.
In this case we oversample our sawtooth by a factor
of 16x, and run that through a Butterworth low-pass
filter with a cutoff of about 15000Hz. 

What this does is reduces foldover in our signal.  
Foldover is when a frequency (or a partial) goes above the Nyquist
frequency (SR/2) it folds back to 0 Hz and subsequently increases 
from there based on how high the partial is.  (e.g a partial of 
26000Hz would actually be 2000Hz at SR=48000. 

To get rid of this, we use anti-aliasing techniques, which in this
case is just oversampling and low-pass filtering our signal.  

This example is based on Pure Data's eample J.07.oversample.pd
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
   music.printCoefs(); //if you don't want to see the filter coefs, remove this.
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    float f = map(mouseX, 0, width, 600, 1100);
    music.setFreq(f);
    background(0);
    textSize(20);
    text("Click to compare", 10, 40);
    
    textSize(36);
    if(compare == 1)
      text("Aliased", width/2.5, height/2);
    else
      text("Anti-Aliased", width/2.5, height/2);
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
   We use two examples of a phasor, one that is anti-aliased, or oversampled.
   And one as is.  You should be able to hear the "cleaner" anti-aliased version
   when compared to the built-in version.
 */
 class MyMusic extends PdAlgorithm {
   
   float freq = 932;
   Phasor phasor = new Phasor();
   int upsample = 16;
   Butterworth butterworth = new Butterworth(15000, this.getSampleRate()*upsample*.5, 0, upsample);
   boolean compare = false;
   

   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     if(!compare)
     {
       double [] buffer = new double[upsample];
       for(int i = 0; i < upsample; i++)
           buffer[i] = butterworth.perform(phasor.perform( getFreq() / upsample )) * .2; 
       
       outputL = outputR = buffer[0];
     }
     else
     {
       outputL = outputR = phasor.perform( getFreq() ) * .2;
     }
     
   }
   
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f) {
     freq = f;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   synchronized void setCompare(boolean b)  {
      compare = b; 
   }
   
   synchronized void printCoefs() {
      println("FILTER COEFS");
      println("Low Pass");
      println(butterworth.getLowPass());
      println("High Pass");
      println(butterworth.getHighPass());
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Phasor.free(phasor);
     butterworth.free();
   }
   
 }
