class RandomHold {
 
  SampleHold samphold = new SampleHold();
  Noise noise = new Noise();
  
  double perform(double input, double w, double c) {
    double output = 0;
    output = samphold.perform( (noise.perform() * w) + c, input);
    return output;
  }
  
  public void free() {
     SampleHold.free(samphold); 
     Noise.free(noise);
  }
  
}
