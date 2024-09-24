
/*
The actual percussive envelope in the original is unclear
exactly how it is implemented. 
There is a Nyquist function called "exp-dec" which uses
something called Piece-Wise Approximations.
https://www.cs.cmu.edu/~rbd/doc/nyquist/part8.html#92

This however, does relatively the same thing, it creates
an exponential decay based on a half-life of 10.

*/

class PercussionEnvelope extends PdMaster {
  
  Line line = new Line();
  double hl = 10;
  public double perform(double dur, boolean bang) {
        
        if(bang)
          line.perform(0,0);
          
        double halflife = (log(2)/hl) * -1;
        double l = line.perform(120, dur*1000) * halflife;
        double output = exp((float)l);
        
        if(output <= .0005)
          output = 0;
        
        return output;
    
  }
  
  public void free() {
    Line.free(line);
  }
  
  
}
