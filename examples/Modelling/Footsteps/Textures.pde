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
  
  //grass
  Noise grass_noise = new Noise();
  LowPass grass_lop1 = new LowPass();
  LowPass grass_lop2 = new LowPass();
  LowPass grass_lop3 = new LowPass();
  HighPass grass_hip1 = new HighPass();
  HighPass grass_hip2 = new HighPass();
  Oscillator grass_osc = new Oscillator();
  VoltageControlFilter grass_vcf = new VoltageControlFilter();
  
  //dirt
  Noise dirt_noise = new Noise();
  LowPass dirt_lop = new LowPass();
  Oscillator dirt_osc1 = new Oscillator();
  Oscillator dirt_osc2 = new Oscillator();
  HighPass dirt_hip = new HighPass();
  
  //gravel
  Noise gravel_noise = new Noise();
  LowPass gravel_lop1 = new LowPass();
  LowPass gravel_lop2 = new LowPass();
  LowPass gravel_lop3 = new LowPass();
  HighPass gravel_hip1 = new HighPass();
  HighPass gravel_hip2 = new HighPass();
  VoltageControlFilter gravel_vcf = new VoltageControlFilter();
  
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
  
  //grassy
  public double grass(double input) {
    double output = 0;
    if(env2.perform(input) > .5)
    {
      double n = grass_noise.perform();
      grass_hip1.setCutoff(2500);
      grass_lop1.setCutoff(300);
      grass_lop2.setCutoff(2000);
      grass_lop3.setCutoff(16);
      grass_vcf.setQ(1);
      grass_hip2.setCutoff(900);
  
      double a = grass_hip1.perform( grass_lop1.perform(n)/grass_lop2.perform(n) );
      double filterInput = clip( ( (a*a*a*a)*1e-05 ), -0.9, 0.9);
      double filterFreq = clip( (grass_lop3.perform(n) *23800)+3400, 2000, 10000);
      double [] vcfOut = grass_vcf.perform(filterInput, filterFreq);
      double y = input * (grass_hip2.perform( vcfOut[0] ) * .3);
    
      double b = input*input*input*input;
      double c = clip( grass_osc.perform( (b*600)+30), 0, .5 );
      double x = (c*b) * .8;
      output = x + y;
    }
    
    return output;
  }
  
  //let's get dirty
  public double dirt(double input) {
    double output = 0;
    if(env3.perform(input) > .5)
    {
      dirt_lop.setCutoff(80);
      dirt_hip.setCutoff(200);
      double a = input * input * input * input;
      double x = a * dirt_osc1.perform( (a * 500) + 40 ) * .5;
      double n = dirt_lop.perform(dirt_noise.perform()) * 70;
      double b = (input + .3) * n;
      double y = clip( dirt_hip.perform( dirt_osc2.perform ((b*70)+70) ), -1, 1 ) * .04;
      output = x + y;
    }
    
    return output;
  }
  
  //hit the gravel
  public double gravel(double input) {
    double output = 0;
    if(env4.perform(input) > .5)
    {
      gravel_lop1.setCutoff(300);
      gravel_lop2.setCutoff(2000);
      gravel_hip1.setCutoff(400);
      gravel_hip2.setCutoff(200);
      gravel_lop3.setCutoff(50);
      double n = gravel_noise.perform();
      double a = gravel_hip1.perform( gravel_lop1.perform(n)/gravel_lop2.perform(n) );
      double filterInput = clip( (a*a)*.01, -.9, .9);
      double b = (input * 1000) + ( gravel_lop3.perform(n) * 50000);
      double filterFreq = clip(b, 500, 10000);
      double [] vcfOut = gravel_vcf.perform(filterInput, filterFreq);
      double y = gravel_hip2.perform(vcfOut[0]) * 2;
      output = input * y;
    }
    return output;
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
    
    //free grass
    Noise.free(grass_noise);
    LowPass.free(grass_lop1);
    LowPass.free(grass_lop2);
    LowPass.free(grass_lop3);
    HighPass.free(grass_hip1);
    HighPass.free(grass_hip2);
    Oscillator.free(grass_osc);
    VoltageControlFilter.free(grass_vcf);
    
    //free dirt
    Noise.free(dirt_noise);
    LowPass.free(dirt_lop);
    Oscillator.free(dirt_osc1);
    Oscillator.free(dirt_osc2);
    HighPass.free(dirt_hip);
    
    //free gravel
    Noise.free(gravel_noise);
    LowPass.free(gravel_lop1);
    LowPass.free(gravel_lop2);
    LowPass.free(gravel_lop3);
    HighPass.free(gravel_hip1);
    HighPass.free(gravel_hip2);
    VoltageControlFilter.free(gravel_vcf);
    
  }
}
