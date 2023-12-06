class Textures {
  
  Envelope env1 = new Envelope();
  Envelope env2 = new Envelope();
  Envelope env3 = new Envelope();
  Envelope env4 = new Envelope();
  Envelope env5 = new Envelope();
  
  //snow
  Noise noise1 = new Noise();
  Noise noise2 = new Noise();
  LowPass lop1 = new LowPass();
  LowPass lop2 = new LowPass();
  LowPass lop3 = new LowPass();
  LowPass lop4 = new LowPass();
  LowPass lop5 = new LowPass();
  HighPass hip = new HighPass();
  VoltageControlFilter vcf = new VoltageControlFilter();
  
  //you know nothing, john snow
  public double snow(double input) {
    double output = 0;
    if(env1.perform(input) > .5)
    {
      double n1 = noise1.perform();
      double n2 = noise2.perform();
      lop1.setCutoff(50);
      lop2.setCutoff(70);
      lop3.setCutoff(10);
      double a = lop1.perform(n1)/lop2.perform(n1);
      double b = lop3.perform(n1) * 17;
      b *= b;
      b += .5;
      lop4.setCutoff(110);
      lop5.setCutoff(900);
      double c = lop4.perform(n2)/lop5.perform(n2);
      hip.setCutoff(300);
      double filterInput = hip.perform( clip(c * a * b, -1, 1) );
      vcf.setQ(.5);
      double filterCenter = (input * 9000) + 700;
      double [] temp = vcf.perform(filterInput, filterCenter);
      output = (temp[0] * input) * .2;
    }
    return output;
  }
  
  public double grass(double input) {
    return 0;
  }
  
  public double dirt(double input) {
    return 0;
  }
  
  public double gravel(double input) {
    return 0;
  }
  
  public double wood(double input) {
    return 0;
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
  
  public void free() {
    Envelope.free(env1);
    Envelope.free(env2);
    Envelope.free(env3);
    Envelope.free(env4);
    Envelope.free(env5);
    
    //free snow
    Noise.free(noise1);
    Noise.free(noise2);
    LowPass.free(lop1);
    LowPass.free(lop2);
    LowPass.free(lop3);
    LowPass.free(lop4);
    LowPass.free(lop5);
    HighPass.free(hip);
    VoltageControlFilter.free(vcf);
    
    
  }
}
