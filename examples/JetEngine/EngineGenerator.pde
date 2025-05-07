class EngineGenerator {
 
  private double speed = 0;
  private LowPass lop1 = new LowPass();
  private LowPass lop2 = new LowPass();
  //turbine
  private Oscillator[] osc = new Oscillator[5];
  // burn
  private Noise noise = new Noise();
  private BandPass bp = new BandPass();
  private VoltageControlFilter[] vcf = new VoltageControlFilter[2];
  private HighPass hip = new HighPass();
  
  public EngineGenerator() {
      for(int i = 0; i < osc.length; i++)
      {
        osc[i] = new Oscillator();
      }
      
      vcf[0] = new VoltageControlFilter();
      vcf[1] = new VoltageControlFilter();
      
      bp.setCenterFrequency(8000);
      bp.setQ(.5);
      hip.setCutoff(120);
      vcf[0].setQ(1);
      vcf[1].setQ(.6);
  }
  
  public double perform() {
     double output = 0;
     lop1.setCutoff(.2);
     lop2.setCutoff(11000);
     double s = lop1.perform(getSpeed());
     output = lop2.perform( (turbine(s) * .5) + burn(s) ) * .1;
     return output;
  }
  
  private double turbine(double input) {
     double output = 0;
     double[] freqs = {3097, 4495, 5588, 7471, 11000};
     double a = ((osc[0].perform(freqs[0] * input)) + (osc[1].perform(freqs[1] * input))) * .25;
     double b = osc[2].perform(freqs[2] * input);
     double c = ((osc[3].perform(freqs[3] * input)) + (osc[4].perform(freqs[4] * input))) * .4;
     output = clip((a + b + c), -.9, .9);
     return output;
  }
  
  private double burn(double input) {
    double output = 0;
    double[] vcfOut1 = new double[2];
    double[] vcfOut2 = new double[2];
    double cf = (input * input) * 150;
    double a = bp.perform(noise.perform());
    vcfOut1 = vcf[0].perform(a, cf);
    double b = hip.perform(vcfOut1[0]) * 120;
    double c = clip(b, -1, 1);
    vcfOut2 = vcf[1].perform(c, input * 12000);
    return vcfOut2[0];
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
 
 public void setSpeed(double s) {
    speed = s; 
 }
 
 public double getSpeed() {
    return speed; 
 }
  
  public void free() {
    LowPass.free(lop1);
    LowPass.free(lop2);
    
    for(int i = 0; i < osc.length; i++)
    {
       Oscillator.free(osc[i]); 
    }
    
    Noise.free(noise);
    BandPass.free(bp);
    HighPass.free(hip);
    VoltageControlFilter.free(vcf[0]);
    VoltageControlFilter.free(vcf[1]);
  }
  
}
