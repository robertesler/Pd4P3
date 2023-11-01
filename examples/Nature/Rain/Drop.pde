
class Drop {
  
  VoltageControlFilter vcf = new VoltageControlFilter();
  double signal = 0;
  double centerFreq;
  double rain = 0;
  double rainVol = 0;
  double [] vcfOut = new double[2];
  
  public Drop() {
      vcf.setQ(.01);
  }
  
  public double perform(double sig, double cf, double r, double rv) {
    double output = 0;
    vcfOut = vcf.perform(sig, cf);
    double x = max(clip(vcfOut[0], 0 ,1), r);
    double y = x - r;
    double z = y * y;
    output = (z * z) * rv;
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
 
 public void free() {
  VoltageControlFilter.free(vcf); 
 }
 
}
