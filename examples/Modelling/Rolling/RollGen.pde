
/*
This is adapted from the "rolling" example Andy Farnell's book "Designing Sound"

It has three parts, the oscillator that triggers the rolling
and the ground, which feeds into a tin can simulator.

In this example we use the amplitude of a LFO phasor to control
our roll speed.

*/
class RollGen {
  
  Phasor phasor = new Phasor();
  Cosine cos = new Cosine();
  LowPass lop = new LowPass();
  HighPass hip = new HighPass();
  Line line = new Line();
  
  //regularRoll
  Wrap[] wrap = new Wrap[4];
  HighPass rzero = new HighPass();
  Phasor phasor_r = new Phasor();
  
  //irregularGround
  Phasor phasor_g = new Phasor();
  SampleHold samphold = new SampleHold();
  HighPass rzero_g = new HighPass();
  Noise noise = new Noise();
  
  //tinCan
  BandPass[] bp = new BandPass[4];
  
  public RollGen() {
    for(int i = 0; i < 4; i++)
    {
       wrap[i] = new Wrap(); 
       bp[i] = new BandPass();
    }
    //set our filters here
    lop.setCutoff(.1);
    hip.setCutoff(200);
    rzero.setCutoff(9000);
    rzero_g.setCutoff(13000);
    bp[0].setCenterFrequency(359);
    bp[1].setCenterFrequency(426);
    bp[2].setCenterFrequency(1748);
    bp[3].setCenterFrequency(3000);
    bp[0].setQ(123);
    bp[1].setQ(123);
    bp[2].setQ(123);
    bp[3].setQ(123);
  }
  
  public double perform(double amp) {

    double a = ((phasor.perform(.5) * line.perform(amp, 50)) * .5) - .25;
    double speed = lop.perform(cos.perform(a)) * 5;
    double b = regularRoll(speed) +  irregularGround(speed * .5);
    double c = sqrt((float)speed * .1) * b;
    double out = tinCan(hip.perform(c));
    return out;
  }
  
  //This behaves like a noisy, low passed oscillator
  private double regularRoll(double speed) {
    double signal = phasor.perform(speed);
    double a = wrap[0].perform(signal * 2) * .1;
    double b = wrap[1].perform(signal * 3) * .05;
    double c = wrap[2].perform(signal * 4.2) * .02;
    double d = wrap[3].perform(signal * 5.6) * .012;
    double out = rzero.perform(a + b + c + d);
    //println(out * out);
    return out * out;
  }
  
  //a noise generator but with some wiggle and lowpass
  private double irregularGround(double speed) {
    double n = noise.perform();
    double a = max(n, 0);
    double b = (n * .001) + phasor_g.perform(speed * 100);
    double c = samphold.perform(a, b);
    double out = rzero.perform(c) * .05 * speed; 
    return out;
  }
  
  //This emulates a noisy, tuned cylinder
  private double tinCan(double in) {
     double a = bp[0].perform(in) * .2;
     double b = bp[1].perform(in) * .3;
     double c = bp[2].perform(in) * .3;
     double d = bp[3].perform(in) * .2;
     double out = a + b + c + d;
     return clip(out * 1000, -.3, .3) * .4; 
  }
  
     //emulate [clip~], a = input, b = low range, c = high range
   private double clip(double a, double b, double c) {
     if(a < b)
       return b;
     else if(a > c)
       return c;
     else
       return a;
   }
  
  private double max(double a, double b) {
   double max = 0;
   if(a < b)
   {
     max = b;
   }
   if(a > b)
   {
     max = a; 
   }
   return max;
 }
  
  public void free() {
    //tinCan
    for(int i = 0; i < 4; i++)
    {
       BandPass.free(bp[i]);
    }
    
    Phasor.free(phasor);
    Cosine.free(cos);
    LowPass.free(lop);
    HighPass.free(hip);
    Line.free(line);
  
    //regularRoll
    HighPass.free(rzero);
    Phasor.free(phasor_r);
  
    //irregularGround
    Phasor.free(phasor_g);
    SampleHold.free(samphold);
    HighPass.free(rzero_g);
    Noise.free(noise);
  
  }
  
}
