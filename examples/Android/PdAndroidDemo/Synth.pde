class Synth {
  
  Oscillator osc = new Oscillator();
  Line line = new Line();
  double attack = 50;
  double release = 250;
  double env = 0;
  
 double perform(double freq, double amp, boolean on) {
   
   double out = 0;
   if(on)
     {
     env = line.perform(1, attack);  
     }
     else
     {
      env = line.perform(0, release); 
     }
     out = osc.perform(freq) * amp * env;
    
    return out;
       
 }
 
 void free() {
   Oscillator.free(osc); 
   Line.free(line);
 }
  
}
