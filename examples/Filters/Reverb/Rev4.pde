
/*
This is an emulation of Pure Data's rev3~ object.
It has 16 delay lines and 4 early reverberators
Each delay line is mixed across a 5-layer matrix
There are four variables:
output level = 0-100
liveness = 0-100
crossover freq = 0-nyquist
damping = 0-100%
*/

class Rev3 {
  
  private double outputLevel = 0;
  private double liveness = 0;
  private double crossover = 3000;
  private double damping = 0;
  VariableDelay [] delEarly = new VariableDelay[4];
  VariableDelay [] delay = new VariableDelay[16];
  LowPass [] lop = new LowPass[4];
  Line line0 = new Line();
  Line line1 = new Line();
  Line line2 = new Line();
  private double [] earlyDelTime = {1.42763, 3.23873,5.2345, 7.82312};
  private double [] delTime = {10,11.6356, 13.4567, 16.7345, 20.1862, 25.7417, 31.4693, 38.2944,
                        46.6838, 55.4567, 65.1755, 76.8243, 88.5623, 101.278, 115.397, 130.502};
  private double [] early = new double[4];
  private double [] del = new double[16];
  
  public Rev3() {
    
    for(int i = 0; i < delEarly.length; i++)
    {
        delEarly[i] = new VariableDelay();
        lop[i] = new LowPass();
        early[i] = 0;
    }
    
     for(int i = 0; i < delay.length; i++)
    {
        delay[i] = new VariableDelay();
        del[i] = 0;
    }
    
  }
  
  //returns four outputs, the last four delays in the matrix
  public double [] perform(double inputL, double inputR)  {
    double [] output = new double[4];
    double [] earlyReflections = new double[2];
    
    //early reflections
    earlyReflections = computeEarly(inputL, inputR);
    output = doit(earlyReflections[0], earlyReflections[1]);
    double vol = line0.perform(line0.dbtorms(outputLevel), 30);
    vol = vol > 100 ? 100 : vol;
    output[0] *= vol;
    output[1] *= vol;
    output[2] *= vol;
    output[3] *= vol;
    
    return output;
  }
  
  private double [] doit(double inputL, double inputR) {
     
    double [] output = new double[4];
    
     //we write to our delay line
    for(int i = 0; i < delay.length; i++)
    {
       delay[i].delayWrite(del[i]); 
       if(Double.isNaN(del[i]))
       {
         println("NaN top");
       }
    }
    
    //layer 1, damping
    double [] damp = new double[4];
    for(int i = 0; i < delay.length/4; i++)
    {
       double a = delay[i].perform(delTime[i]);
       double b = lop[i].perform(a);
       double c = b - a;
       double kDamping = line1.perform(damping/100, 50);
       kDamping = kDamping > 100 ? 100 : kDamping;
       double d = c * kDamping;
       damp[i] = a + d;
    }
    
    //add our input to the signal chains
    double fb = line2.perform(liveness/400, 35);
    fb = fb > 100 ? 100 : fb;
    //double fb = .225;
    del[0] = (damp[0] + inputL);
    del[1] = (damp[1] + inputR);
    del[2] = damp[2];
    del[3] = damp[3];
    
    for(int i = 4; i < delay.length - 4; i++)
    {
      del[i] = delay[i].perform(delTime[i]);
    }
    
    //layer 2, mixing every other del
    for(int i = 0; i < delay.length; i += 2)
    {
      //double fb = line2.perform(liveness/400, 35);
      double a = del[i] * fb;
      double b = del[i+1] * fb;
      del[i] = a + b;
      del[i+1] = a - b;      
    }
    //layer 3, mix 1 with 3, 2 with 4
    for(int i = 0; i < delay.length; i += 4)
    {
       double a = del[i];
       double b = del[i+1];
       double c = del[i+2];
       double d = del[i+3];
       del[i] = a + c;
       del[i+1] = b + d;
       del[i+2] = a - c;
       del[i+3] = b - d;
    }
    
    //layer 4, mix every four
    for(int i = 0; i < delay.length; i+=8)
    {
       double a = del[i];
       double b = del[i+1];
       double c = del[i+2];
       double d = del[i+3];
       double e = del[i+4];
       double f = del[i+5];
       double g = del[i+6];
       double h = del[i+7];
       del[i] = a + e;
       del[i+1] = b + f;
       del[i+2] = c + g;
       del[i+3] = d + h;
       del[i+4] = a - e;
       del[i+5] = b - f;
       del[i+6] = c - g;
       del[i+7] = d - h;
    }
    
    //layer 5, mix first 8, with second 8
       //1-8
       double a = del[0];
       double b = del[1];
       double c = del[2];
       double d = del[3];
       double e = del[4];
       double f = del[5];
       double g = del[6];
       double h = del[7];
       //9-16
       double i = del[8];
       double j = del[9];
       double k = del[10];
       double l = del[11];
       double m = del[12];
       double n = del[13];
       double o = del[14];
       double p = del[15];
       del[0] = a + i;
       del[1] = b + j;
       del[2] = c + k;
       del[3] = d + l;
       del[4] = e + m;
       del[5] = f + n;
       del[6] = g + o;
       del[7] = h + p;
       del[8] = a - i;
       del[9] = b - j;
       del[10] = c - k;
       del[11] = d - l;
       del[12] = e - m;
       del[13] = f - n;
       del[14] = g - o;
       del[15] = h - p;
    
       
    //write our outputs
    output[0] = del[12];
    output[1] = del[13];
    output[2] = del[14];
    output[3] = del[15];
    
    return output;
    
  }
  
  public void setAll(double ol, double l, double co, double d) {
    outputLevel = ol;
    liveness = l;
    crossover = co;
    damping = d;
    for(int i = 0; i < lop.length; i++)
    {
      lop[i].setCutoff(crossover);
    }
  }
  
  private double [] computeEarly(double inputL, double inputR) {
      double [] output = new double[2];
      
      delEarly[0].delayWrite(inputR);
      early[0] = delEarly[0].perform(earlyDelTime[0]);
      double a = inputL - early[0];
      double b = inputL + early[0] ;
      
      delEarly[1].delayWrite(a);
      early[1] = delEarly[1].perform(earlyDelTime[1]);
      double c = b - early[1];
      double d = b + early[1];
      
      delEarly[2].delayWrite(c);
      early[2] = delEarly[2].perform(earlyDelTime[2]);
      double e = d - early[2];
      double f = d + early[2];
      
      delEarly[3].delayWrite(e);
      early[3] = delEarly[3].perform(earlyDelTime[3]);
      double g = f - early[3];
      double h = f + early[3];
      
      output[0] = g * .3535;
      output[1] = h * .3535;
      
      return output;
  }
  
  public void free() {
    
    Line.free(line0);
    Line.free(line1);
    Line.free(line2);
    
    for(int i = 0; i < delEarly.length; i++)
    {
        VariableDelay.free(delEarly[i]);
        LowPass.free(lop[i]);
    }
    
    for(int i = 0; i < delay.length; i++)
    {
        VariableDelay.free(delay[i]);
    }
    
  }
  
}
