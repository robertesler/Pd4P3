/*
Multichannel Audio 

This demonstrates how you can setup your sketches to 
employ multichannel duplex audio.  It should work well 
with PortAudio which Pd4P3 supports.

It may not work with Java Sound, the default audio
driver that Pd4P3 uses.  

PortAudio for Java is experimental and not fully tested
for high-performance situations. 

See Phil Burk's GitHub: https://github.com/philburk/portaudio-java

This example only supports pairs of channels up to 8 max.  
Theoretically you could alter to employ more or odd numbers too.
*/

import com.pdplusplus.*;
import com.portaudio.*;

/*
Open our Native Library here
We do this because we are bypassing the regular audio 
drivers (either PortAudio stereo (e.g. the Pa class) or Java Sound (e.g. Pd class)

Don't do this unless you are experimenting with multichannel audio.

If this seems to work ok, then perhaps it will be integrated into the 
regular Pd4P3 distribution.
*/

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
 int channels = 8;
 float f = 100;
 
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new Music(channels);
   pd = new PaMulti(channels);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    
   f = map(mouseX, 0, width, 100, 500);
   music.setFreq(f);
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
   
   Oscillator osc = new Oscillator();
   Oscillator osc2 = new Oscillator();
   Oscillator osc3 = new Oscillator();
   Oscillator osc4 = new Oscillator();
   double [] output;
   int chans = 2;
   float freq = 100;
   
   public Music(int ch) {
      chans = ch;
      output = new double[ch]; 
   }
 
   //All DSP code goes here
   void runAlgorithm(double [] in) {
     
     if(chans == 8)
     {
        output[0] = output[1] = osc.perform(freq) * .4;
        output[2] = output[3] = osc2.perform(freq * .667) *.3; 
        output[4] = output[5] = osc3.perform(freq * 2) * .25;
        output[6] = output[7] = osc4.perform(freq * 4) * .25;
     }
     
     if(chans == 6)
     {
        output[0] = output[1] = osc.perform(freq) * .4;
        output[2] = output[3] = osc2.perform(freq * .667) *.3; 
        output[4] = output[5] = osc3.perform(freq * 2) * .25;
     }
     
     if(chans == 4)
     {
        output[0] = output[1] = osc.perform(freq) * .5;
        output[2] = output[3] = osc2.perform(freq * .667) *.5;    
     }
     
     if(chans == 2)
     {
        output[0] = output[1] = osc.perform(freq) * .5;
     }
     
     /*
     //Route input to output, could be a big delay FYI
     for(int i = 0; i < in.length; i++)
     {
        output[i] = in[i]; 
     }
     */
    
   }
   
   synchronized void setFreq(float f) {
      freq = f; 
   }
 
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc);
     Oscillator.free(osc2);
     Oscillator.free(osc3);
     Oscillator.free(osc4);
   }
   
 }
