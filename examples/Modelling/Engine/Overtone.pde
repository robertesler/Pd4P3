class Overtone {
 
   Wrap wrap = new Wrap();
  
  public double perform(double drive, double phase, double freq, double amp) {
     
     double a = max(drive, phase) - phase;
     double b = 1 / (1 - phase);
     double c = phase * (freq * 12);
     double d = a * b * c;
   
     double x = wrap.perform((float)d) - .5; 
     double y = (1 - drive) * ( ( ( (x*x) * -4) + 1) * .5);
     double out = amp * 12 * y; 
     return out; 
  }
  
   //emulate [max~] a = input, b = input2, always return the higher value
 private double max(double a, double b) {
   double max = 0;
   if(a <= b)
   {
     max = b;
   }
   if(a >= b)
   {
     max = a; 
   }
   return max;
 }
  
}
