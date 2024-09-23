class PercussionEnvelope extends PdMaster {
  
  Line line = new Line();
  double hl = 10;
  public double perform(double dur, boolean bang) {
        
        if(bang)
          line.perform(0,0);
          
        double halflife = (log(2)/hl) * -1;
        double l = line.perform(100, dur*1000) * halflife;
        double output = exp((float)l);
        return output;
    
  }
  
  public void free() {
    Line.free(line);
  }
  
  
}
