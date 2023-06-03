/*
  This is an example of a pink noise generator.
  You can compare the two by moving the mouse 
  across the window. 
  
  Most of the code to create the generator was
  written by Phil Burk or others as noted.  
  
  It emulates the Gardner method of generating 
  pink noise.  Pink noise is where the spectral
  density is inversely proportional to the frequency
  of the signal.  So pink noise has more low frequencies
  than white noise by amplitude.  Sometimes it is called
  1/f noise.

*/
import com.pdplusplus.*;

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
   //go from white to pink
   float gb = map(mouseX, 0, width, 255, 196);
   background(255, gb, gb);
   
   //crossfade the two noise signals with the mouse
   double p = map(mouseX, 50, width-50, 0, 1);
   music.setPan(p);
   
   String s = "White | Pink";
   fill(100);
   textSize(50);
   text(s, (width/2)-140, height/2);
   
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 
 /*
   This is where we call our pink and white noise generators.
 */
 class MyMusic extends PdAlgorithm {
   
   double pan = 0;
   Pink pink = new Pink();
   Noise noise = new Noise();
   Line lineL = new Line();
   Line lineR = new Line();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     //this is stupid code but it just protects our values going above 1 and below 0
     double cPan = getPan()<0?0.0 : getPan()>1?1.0 : getPan();
     double w = noise.perform();
     double p = pink.perform(); 
     /*
     crossfade between white and pink noise, we use line to reduce zipper noise
     even though it probably wouldn't be audible with the noise signal.  But we 
     are pros and that is how it should be done.
     */
     double cp1 = lineL.perform(1-cPan, 25);
     double cp2 = lineR.perform(cPan, 25);
     outputL = w*cp1 + p*cp2;
     outputR = w*cp1 + p*cp2;
   }
  
  
  //We use synchronized to communicate with the audio thread
   synchronized void setPan(double p) {
     pan = p;
   }
   
   synchronized double getPan() {
     return pan;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     Line.free(lineL);
     Line.free(lineR);
   }
   
 }
