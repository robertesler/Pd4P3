class Synth {
  
  Phasor phasor = new Phasor();
  VoltageControlFilter vcf = new VoltageControlFilter();
  float freq = 300;
  
  public double perform() {
    double[] out = vcf.perform( phasor.perform( getFreq() ), freq*2 );
   return out[0]; 
  }
  
  synchronized void setFreq(float f) {
    freq = f;
  }
  
  synchronized float getFreq() {
      return freq;
  }
  
  public void free() {
    Phasor.free(phasor);
    VoltageControlFilter.free(vcf);
  }
  
}
