/*
This class creates a bing.  It is just two oscillators,
one for the pitch and one for the vibrato.  The pitch osc
is gently distorted (see clip() ) and filtered (lop).  Then it is shaped using
an exponential envelope curve for a smooth decay

I've added reverb via the ReverbDemo.pde example and tweaked it a bit.
*/


class Bing extends PdMaster {
  
  Oscillator osc1 = new Oscillator();
  Oscillator osc2 = new Oscillator();
  Line line2 = new Line();
  Line line1 = new Line();
  LowPass lop = new LowPass();
  boolean bang = false;
  double amp = 0;
  double decay = 1400;
  
 public double perform(double p) {
   double out= 0;
   
   
   double firstPhase = osc1.perform(this.mtof(p)) * amp;
   firstPhase = clip(firstPhase, -.7, .7);
   lop.setCutoff(this.mtof(p)*2);
   firstPhase = lop.perform(firstPhase);
   double secondPhase = osc2.perform( line2.perform(.8, decay) ) * .7; 
   out = firstPhase * secondPhase * 5;//mult. by a constant for loss of gain

   if(getBang())
   {
      amp = line1.perform(1, 10);
      line2.perform(1.2, 0);
      osc1.setPhase(-.25);
      osc2.setPhase(-.25);
   }
   else
   {
      amp = envelope(decay); 
   }
   
   if(amp == 1)
   {
      bang = false; 
   }
   
   
    return out;
 }
 
 private double clip(double a, double b, double c) {
    
     double t = (a < b ? b : a);
     t = (t > c ? c : t);
     return t;
    
   
 }
 
 private double envelope(double decay) {
   double env = 0;
   env = line1.perform(0, decay);
   env = sin((float)env);
   env = env*env*env;
   return env;
 }
 
 synchronized void setBang(boolean b) {
   bang = b;
 }
 
 synchronized boolean getBang() {
   return bang;
 }
 
 public void free() {
   Oscillator.free(osc1);
   Oscillator.free(osc2);
   Line.free(line2);
   Line.free(line1);
   LowPass.free(lop);
 }
  
}
