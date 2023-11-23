import com.pdplusplus.*;

/*
This is a basic resonant filter as created by
the RjDj.  It uses two poles and two zeros.
Be careful with the scale variable, see my note below. 
X = Frequency
Y = Q factor
*/
 Pd pd;
 MyMusic music;
 
 double freq = 100;
 double q;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   pd.setSampleRate(44100);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  freq = map(mouseX, 0, width, 50, 1000);
  music.setFreq(freq);
  q = map(mouseY, height, 0, .2, 30);
  music.setQ(q);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 class MyMusic extends PdAlgorithm {
   
   RealZero rzero1 = new RealZero();
   RealZero rzero2 = new RealZero();
   ComplexPole cpole1 = new ComplexPole();
   ComplexPole cpole2 = new ComplexPole();
   Noise noise = new Noise();
   double freq = 100;
   double q = 1;
   int scale = 2;
   
   //4 stage 2-pole, 2-zero resonant filter
   void runAlgorithm(double in1, double in2) {
     double output = 0;
     double n = noise.perform();
     double stage1 = rzero1.perform(n, -1);
     double stage2 = rzero2.perform(stage1, 1);
     double [] f = getFreq();
     double [] stage3 = cpole1.perform(stage2, 0, f[0], f[1]);
     double [] stage4 = cpole2.perform(stage3[0], stage3[1], f[0], f[1]*-1);
     output = stage4[0] * getScale();
     outputL = outputR = output*(1/(float)scale); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(double f1) {
     freq = f1;
   }
   
   //returns real and imaginary parts, 2*PI*T
   synchronized private double [] getFreq() {
     double [] output = {0,0};
     float twoPiT = (float)freq * ( (atan(1) * 8)/noise.getSampleRate() );
     double sin = sin(twoPiT);
     double cos = cos(twoPiT);
     output[0] = cos * getQ();
     output[1] = sin * getQ();
     return output;
   }
   
   synchronized void setQ(double _q) {
     q = _q;
   }
   
   //PI * B * T
   synchronized private double getQ() {
     double  output = 0;
     if(q <= 0) q = .001;
     double i = freq / q;
     float piBT = (float)i * (atan(1) * -4)/noise.getSampleRate();
     output = exp(piBT);
     
     return output;
   }
   
   synchronized void setScale(int s) {
     scale = s;
   }
   
   /*
   When creating raw filters you need a gain scale.
   The following cases are possible gain components.
   Case 0 is no gain scale, WHICH IS VERY LOUD!!!
   So you would need your own custom gain algorithm.
   Case 1 and 2 are (1-r^2)/2 or sqrt((1-r^2)/2) respectively.
   Be carefule with these numbers.
   */
   synchronized double getScale() {
     switch(scale)
     {
        case 0:
        {
          return 1;
        }
        case 1:
        {
          double i = (1 - (getQ() * getQ())) * .5;
          return i;
        }
        case 2:
        {
         double i = (1 - (getQ() * getQ())) * .5;
         return sqrt((float)i);
        }
        default:
        {
          double i = (1 - (getQ() * getQ())) * .5;
          return i;
        }
     }
   
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     RealZero.free(rzero1);
     RealZero.free(rzero2);
     ComplexPole.free(cpole1);
     ComplexPole.free(cpole2);
     Noise.free(noise);
     
   }
   
 }
