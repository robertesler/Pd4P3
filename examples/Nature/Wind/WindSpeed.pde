/*
In the original patch, Andy uses a chain of low pass
filters with a high pass set at 0 for the gust and 
squall. 

That is essentially a band pass so I used just two
bandpass filters to achieve roughly the same effect.

Otherwise it is identical to Andy Farnell's patch.

*/

class WindSpeed {
 
  Oscillator osc = new Oscillator();
  Noise noise = new Noise();
  BandPass bp1 = new BandPass();
  
  Noise noise2 = new Noise();
  BandPass bp2 = new BandPass();

  public double perform(double f) {
    double out = 0;
    double w = (osc.perform(f) + 1) * .25;
    double gust = gust(w);
    double squall = squall(w);
    double mix = w + gust + squall;
    out = clip(mix, 0, 1);
    return out;
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
 
 //emulate [max~] a = input, b = input2, always return the higher value
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
  
  private double gust(double input) {
    double out = 0;
    bp1.setCenterFrequency(.25);
    double n = noise.perform();
    double b = bp1.perform(n)*25;
    //println(b);
    double i = ( (input + .5) * (input + .5) ) - .125;
    out = b * i;
    return out;
  }
  
  private double squall(double input) {
    double out = 0;
    bp2.setCenterFrequency(1.5);
    double i = (max(input, .4) - .4) * 8;
    i *= i;//squared
    double n = noise.perform();
    double b = bp2.perform(n) * 10;
    
    out = b * i;
    return out;
  }
  
  public void free() {
    Oscillator.free(osc);
    
    Noise.free(noise);
    BandPass.free(bp1);
    
    Noise.free(noise2);
    BandPass.free(bp2);
  }
}
