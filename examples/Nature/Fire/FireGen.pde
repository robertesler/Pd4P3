class FireGen {
  
  Noise noise = new Noise();
  LowPass lop = new LowPass();
  LowPass lop2 = new LowPass();
  HighPass hip = new HighPass();
  HighPass hip2 = new HighPass();
  HighPass hip3 = new HighPass();
  Envelope env = new Envelope();
  BandPass bp = new BandPass();
  BandPass bp2 = new BandPass();
  Line line = new Line();
  private double crackleVol = 0;
  double bpCf = 0;
  
  public FireGen() {
    line.setSampleRate(44100);
    lop.setCutoff(1);
    lop2.setCutoff(1);
    bp.setQ(1);
    bp.setCenterFrequency(4000);
    bp2.setQ(5);
    bp2.setCenterFrequency(30);
    hip.setCutoff(1000);
    hip2.setCutoff(25);
    hip3.setCutoff(25);
  }
  
  public double perform() {
    double output = 0;
    double n = noise.perform();
    double crack = crackles(n);
    double hiss = hissing(n);
    double lap = lapping(n);
    
    output = (crack * .2) + (hiss * .3) + (lap * .6);
    return output;
  }
  
  private double crackles(double input) {
    double output = 0;
    double low = lop.perform(input);
    double moses = env.perform(low);
    boolean bang = false;
    float rand;
    int time = 0;
  
    if(moses >= 50.5 && moses <= 51)
    {    
 
      rand = random(0,20);
      bang = true;   
      bpCf = (rand * 500) + 1500;
      time = (int)rand;
    }
 
    if(bang)
    {
      crackleVol = 1;
      line.perform(1, 1);
    }
    else
      crackleVol = line.perform(0, time);

    double vol = crackleVol * crackleVol; // square the volume
    bp.setCenterFrequency(bpCf);
    output = bp.perform(input) * vol;
    return output;
  }
  
  
  private double hissing(double input) {
    double output = 0;
    lop2.setCutoff(1);
    double tempV = lop2.perform(input) * 10;
    double vol = ((tempV * tempV) * (tempV * tempV)) * 600; 
    hip.setCutoff(1000);
    output = hip.perform(input) * vol;
    return output;
  }
  
  private double lapping(double input) {
    double output = 0; 
    hip2.setCutoff(20);
    hip3.setCutoff(20);
    bp2.setQ(5);
    bp2.setCenterFrequency(25);
    double clippedVal = hip2.perform( (bp2.perform(input) * 100) );
    double clipped = clip(clippedVal, -.9, .9);
    output = hip3.perform(clipped) * .6;
    return output;
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
   Noise.free(noise); 
   LowPass.free(lop);
   LowPass.free(lop2);
   HighPass.free(hip);
   HighPass.free(hip2);
   HighPass.free(hip3);
   Envelope.free(env);
   BandPass.free(bp);
   BandPass.free(bp2);
   Line.free(line);
  }
  
  
}
