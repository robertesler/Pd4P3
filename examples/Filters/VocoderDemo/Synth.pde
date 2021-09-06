/*
This class uses a square wave as the carrier
that is filtered based on the input from the 
vocoder's filter bank.  
*/

class Synth {
 
  int numOfFilters = 20;
  int tabSize = 200;
  Oscillator osc = new Oscillator();
  VoltageControlFilter[] vcf  = new VoltageControlFilter[numOfFilters];
  
  double[] envTable = new double[numOfFilters];
  double[] vcfOut = new double[2];
  double[] cfTable;
  
  public double perform(double f){
    /*
    This step converts an oscillator into a square wave
    */
    double s = (osc.perform(f) > 0 ? 1 : -1);
    
    
    /*
    Now we run our PAF synth through an idential filter banks as our source.
    This will create a filter envelope with the stamp of the source.
    */
    double out = 0;
    double[] t = getEnvelope();
    for(int i = 0; i < numOfFilters; i++)
    {
       vcfOut = vcf[i].perform(s, cfTable[i]);
       out += vcfOut[0] * t[i];
    }
    
    return out;
  }
  
  public void setSynth() {
    
   for(int i = 0; i < numOfFilters; i++)
   {
      vcf[i] = new VoltageControlFilter();
      vcf[i].setQ(7.628);
   }
   
   
  }
  
  public void setCfTable(double[] t) {
     cfTable = t; 
  }
  
  public void setEnvelope(double[] en) {
    for(int i = 0; i < numOfFilters; i++)
   {
       envTable[i] = en[i];
   }
    
  }
  
  public double[] getEnvelope() {
     return envTable; 
  }
  
  public void free() {
    
    Oscillator.free(osc);
    //free our filter bank
    for(int i = 0; i < numOfFilters; i++)
     {
        VoltageControlFilter.free(vcf[i]); 
     }
   
  }
  
}
