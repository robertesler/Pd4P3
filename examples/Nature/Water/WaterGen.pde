class WaterGen {
  
  Metro metro = new Metro();
  Line line = new Line();
  Oscillator osc = new Oscillator();
  LowPass lop = new LowPass();
  private double previousSample = 0;
  private long sampleRate = 44100;
  private double bexp = 0;
  
  public WaterGen() {
    osc.setSampleRate(sampleRate); 
  }
  
  /*
   This takes our bilinear random number to generate
   frequencies to our oscillator * an envelope generator. 
  */
  public double perform(double rate, double freq, double depth, double slew) {
    double output = 0;
    boolean bang = metro.perform(rate, sampleRate);
    if(bang)
    {
      bexp = bilexp();
      bexp *= freq;
      bexp += depth;
    }
    double f = line.perform(bexp, slew);
    double fexpr = f - previousSample;//emulates our FIR filter
    double c = clip(fexpr, 0, 1);
    lop.setCutoff(10);
    double v = lop.perform(c) * .9;
    output = osc.perform(f) * v*v;
    previousSample = f;
    return output*2;
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
  
  //This is a bilinear exponential random number generator, a la Andy Farnell
  private double bilexp() {
    double be = 0;
    double r = random(0, 8192);
    double m = r % 4096;
    double x = exp((float)(m/4096)*9);
    double v = 0;
    
    if(r > 4096) 
      v = 1;
    else
      v = -1;
     
    be = (x * v)/23000; 
    return be;
  }
  
  public void free() {
    Line.free(line);
    Oscillator.free(osc);
    LowPass.free(lop);
  }
  
}
