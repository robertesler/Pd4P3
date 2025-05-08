import com.pdplusplus.*;

/*
This is an example of a Peaking EQ filter, and how you could
create a custom filter using your own recipe.
This is our biquad transfer function
H(z) = b0 + b1*z^-1 + b2*z^-2/ a0 + a1*z^-1 + a2*z^-2

These are collective coefficients

fb1 = a1/a0
fb2 = a2/a0
ff1 = b0/a0
ff2 = b1/a0
ff3 = b2/a0

Taken from the "Cookbook Formulae for Audio EQ Biquad Filter Coefficients" 
by Robert Bristow-Johnson <robert@wavemechanics.com>

our formula: H(s) = (s^2 + s*(A/Q) + 1)/ (s^2 + s(A*Q) + 1)
b0 = 1 + alpha*A
b1 = -2*cos
b2 = 1 - alpha*A
a0 = 1 + alpha/A
a1 = -2*cos
a2 = 1 - alpha/A
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
   
   float alpha = 0;//sin(omega)/(2*Q) or sin(omega)*sinh[ln(2)/2 * bw * omega/sin(omega)]
   //sinh = (e^x - e^-x)/2
   float A = 0;//10^(dBgain/40)
   float omega = 0; //2*pi*freq/sr
   float pi = 3.14159;
   float ff1, ff2, ff3, fb1, fb2;
   float a0, a1, a2, b0, b1, b2;
   float freq = 0;
   float dbGain = 0;
   float bw = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = 0; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setAlpha(float a) {
     
   }
   
   synchronized float getAlpha() {
     return alpha;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     
     
   }
   
 }
