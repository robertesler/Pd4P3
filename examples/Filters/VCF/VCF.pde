import com.pdplusplus.*;
import com.portaudio.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq1 = 400;
 float q = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   freq1 = map(mouseX, 0, width, 400.0, 1000.0);
   q = map(mouseY, 0, height, 1.0, 60.0);
   music.setFreq(freq1);
   music.setQ(q);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Print this when sketch is stopped.");
    super.dispose();
}
 
 
 class MyMusic extends PdAlgorithm {
   
   //create new objects like this
    Noise noise = new Noise();
    VoltageControlFilter vcf = new VoltageControlFilter();
    float oscFreq = 300;
    float myQ = 1;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double[] out = vcf.perform( noise.perform(), getFreq());
     vcf.setQ(getQ());
     outputL = outputR =  (out[0] + out[1]) * getQ() * .333;//psuedo normalize amplitude
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     oscFreq = f1;
     notify();//this tells audio thread something has happened.
   }
   
   synchronized float getFreq() {
     return oscFreq;
   }
   
   synchronized void setQ(float q) {
     myQ = q;
     notify();
   }
   
   synchronized float getQ() {
     return myQ;
   }
   
   void free() {
     Noise.free(noise);
     VoltageControlFilter.free(vcf);
     
   }
   
 }
