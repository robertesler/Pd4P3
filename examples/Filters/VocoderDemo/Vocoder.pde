/*
This class implements a simple 20 band classic analog style
vocoder.  

The cfTable stores our bands.  You can adjust as you like, or
create them procedurely.  These are a log distribution across
80 - 12000 via 20 bands

The q is set so that the logarithmic curve of the frequencies
selected creates an overlap of -3dB between bands.
So the first two bands 80 and 104. are about 24 Hz apart, so at 12Hz on 
either side of the center frequency (e.g. 92 Hz) there is a
-3 dB drop in amplitude, so 92.0704235/12.0704235 = 7.628.  This is roughly 
the case for all frequencies across our spectrum.
*/

class Vocoder extends PdMaster {
 
  int numOfFilters = 20;
  VoltageControlFilter[] vcf = new VoltageControlFilter[numOfFilters];
  Envelope[] env = new Envelope[numOfFilters];
  Synth synth = new Synth();
  double freq = 200;
  double q = 7.628;
  double[] envTable = new double[numOfFilters];
  double[] vcfOut = new double[2];
  final double[] cfTable = {80, 104.140847, 135.566645, 176.475062, 229.728281, 
                      299.051222, 389.293095, 506.766408, 659.688538, 858.756539,
                      1117.895418, 1455.232197, 1894.363921, 2466.008292, 3210.152406,
                      4178.85, 5439.862085, 7081.39807, 9218.284918, 12000};
                      
  
  public double perform(double in) {
    double synthOut = 0;
    
    /*
    This is our analysis phase, take our filter bank and get the
    dB level of the output using Envelope.
    */
    for(int i = 0; i < numOfFilters; i++)
    { 
       vcfOut = vcf[i].perform(in, cfTable[i]);
       envTable[i] = this.dbtorms(env[i].perform(vcfOut[0]));    
    }
    
    setEnvelope(envTable);
    synthOut = synth.perform(getFreq());
    
    return synthOut * q/3.14159;
  }
  
  public void setVocoder() {

    for(int i = 0; i < numOfFilters; i++)
    {
       vcf[i] = new VoltageControlFilter();
       env[i] = new Envelope();
       vcf[i].setQ(q); 
       envTable[i] = 0;
    }
    synth.setSynth();
    synth.setCfTable(cfTable);
  }


  synchronized void setEnvelope(double[] en) {
     for(int i = 0; i < numOfFilters; i++)
     {
         envTable[i] = en[i];
     }
     synth.setEnvelope(envTable);
  }
  
  synchronized double[] getEnvelope() {
    return envTable;
  }
  
  synchronized int getNumOfFilters() {
     return numOfFilters; 
  }
  
  synchronized void setFreq(double f) {
     freq = f; 

  }
  
  synchronized double getFreq() {
    return freq;  
  }

  
  public void free() {
    
    for(int i = 0; i < numOfFilters; i++)
    {
       VoltageControlFilter.free(vcf[i]);
       Envelope.free(env[i]);
    }
    synth.free();
    
  }
  
  }
