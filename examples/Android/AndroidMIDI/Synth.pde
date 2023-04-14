class Synth {
  
  Phasor osc = new Phasor();
  Line line = new Line();
  double attack = 50;
  double release = 250;
  double env = 0;
  
 double perform(double freq, double amp, boolean on) {
   
   double out = 0;
   if(on)
     {
     env = line.perform(amp, attack);  
     }
     else
     {
      env = line.perform(0, release); 
     }
     out = osc.perform(freq) * env;
    
    return out;
       
 }
 
 void free() {
   Phasor.free(osc); 
   Line.free(line);
 }
  
}
