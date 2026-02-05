/*
A straight forward vibraphone generator.
Here we use an array of Cosine objects
to calculate our harmonics from a single phasor.
This way, all harmonics will be in phase.  
We also exponentially decrease our decay the 
higher our harmonics, just like most mallet
keyboard instruments. 

*/

class VibeGen {
  
  Phasor phasor = new Phasor();
  Cosine [] cos = new Cosine[9];
  int [] harmonic = {1, 2, 3, 4, 5, 9, 10, 16, 21};
  int [] envExp = {1, 3, 3, 3, 4, 4, 4, 5, 5};
  float [] amp = {1, .125, .125, .3, .075, .1, .015, .015, .015};
  
  LowPass lop = new LowPass();
  Oscillator osc = new Oscillator();
  Line line = new Line();
  Line vibratoLine = new Line();
  Line expLine = new Line();
  double vibratoDecay = 0;
 
  public VibeGen() {
    
    for(int i = 0; i < cos.length; i++)
    {
       cos[i] = new Cosine();
    }
  }
  
  public double perform(double freq) {
    //this increases the decay for lower notes
    double d = sqrt((float)(400/freq)) * 4;
    vibratoDecay = d * 1000;
    double env = exponentialDecay(d);
    double output = barGenerator(freq, env);
    double v = osc.perform(vibrato()) * env;
    lop.setCutoff(freq * 2);
    return lop.perform(output) * v;
  }
  
  //reset our lines and phase.
  public void setAttack() {
    //Changing the phase will change the attack sound
     phasor.setPhase(.25);  
     vibratoLine.perform(2.4, 0); 
     expLine.perform(0, 0); 
  }
  
  //our additive synthesizer
  private double barGenerator(double freq, double env) {
    double output = 0;
    double ph = phasor.perform(freq);
    for(int i = 0; i < cos.length; i++)
    {
       double oscillator = ph * harmonic[i];
       output += cos[i].perform(oscillator) * pow((float)env, envExp[i]) * amp[i];
    }
    
    return output * .75;
  }
  
  //a basic vibrato
  private double vibrato() {
    double output = 0;
    output = vibratoLine.perform(.8, vibratoDecay); 
    return output;
  }
  
  //creates a slow, exponetial decay
  private double exponentialDecay(double duration) {
     double output = 0;
     double a = expLine.perform(100, duration * 1000);
     double b = (log(2)/10) * -1;
     output = exp((float)(a * b));

     return output;
  }
  
  public void free() {
      Phasor.free(phasor);
      for(int i = 0; i < cos.length; i++)
      {
         Cosine.free(cos[i]); 
      }
      LowPass.free(lop);
      Oscillator.free(osc);
      Line.free(line);
      Line.free(vibratoLine);
      Line.free(expLine);
  }
  
}
