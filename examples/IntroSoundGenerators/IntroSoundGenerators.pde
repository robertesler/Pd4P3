import com.pdplusplus.*;

/*
The first thing we will learn is about our sound generators.
In Pd++ we have several sound generators:
Oscillator (Sine Wave)
Noise (White Noise)
Phasor (Sawtooth, ramp)
Cosine (a cosine lookup, won't generate sound without phase generator)
From these we can get almost any other type of generator.
*/

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
  float freq = map(mouseX, 0, width, 100, 500);
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
   You could also put this class in a new tab
 */
 class MyMusic extends PdAlgorithm {
   
   float freq = 0;
   Oscillator osc = new Oscillator();
   Noise noise = new Noise();
   Phasor phasor = new Phasor();
   Cosine cos = new Cosine();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     //uncomment lines to hear different generators, make sure only one line is uncommented
     
     //sine wave, amplitude is scaled by a number 0-1
     outputL = outputR = osc.perform(getFreq()) * .3; 
     
     //white noise
     //outputL = outputR = noise.perform() * .3;
     
     //phasor, or sawtooth, 
     //outputL = outputR = phasor.perform(getFreq()) * .3;
     
     /*
     you can also generate a sine wave this way too.
     Phasor outputs a number 0-1 at the input freq, 
     cos then calculates the cosine component, e.g a cosine wave
     FYI, Oscillaotr is also technically a Cosine wave, meaning it's phase starts at 1 not 0.
     */
     //outputL = outputR = cos.perform( phasor.perform(getFreq()) ) * .3;
     
     //If you want something like a square wave you can do it this way.
     /*
     double x = osc.perform(getFreq());
     if(x > 0)
       x = 1;
     else
       x = -1;
     outputL = outputR = x * .3;
     */
     
     //or this way
     /*
     double x = phasor.perform(getFreq());
     x -= .5;
     if(x > 0)
       x = 1;
     else
       x = -1;
     outputL = outputR = x * .3;
     */
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f) {
     freq = f;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc);
     Noise.free(noise);
     Phasor.free(phasor);
     Cosine.free(cos);
   }
   
 }
