class CricketGen {
  
  Phasor phasor = new Phasor();
  Cosine cos1 = new Cosine();
  Cosine cos2 = new Cosine();
  Cosine cos3 = new Cosine();
  
  /*
   To generate our cricket we basically created
   a simple buzzer and applied amplitude modulation 
   using the same phasor.
  */
  
  public double perform(double rate) {
    double r = phasor.perform(rate);
    double x = cos1.perform(r*40.6);
    x *= x;//x^2
    double y = ( cos2.perform(r*3147)) + ( (cos3.perform(r*3147*2)) * .3);
    double vol = x * y;
    double a = min(r, .1714) * 5.84;
    double b = wrap(a) - .5;
    double c = ( (b*b) * -4 ) + 1;
    double output = c * vol;
    return output * .1;
  }
  
  //emulate [max~] a = input, b = input2, always return the higher value
 private double min(double a, double b) {
   double min = 0;
   if(a < b)
   {
     min = a;
   }
   if(a > b)
   {
     min = b; 
   }
   return min;
 }
  
  private double wrap(double input) {
    double frac = input % 1;
   return frac;
  }
  
  public void free() {
    Phasor.free(phasor);
    Cosine.free(cos1);
    Cosine.free(cos2);
    Cosine.free(cos3);
  }
  
}
