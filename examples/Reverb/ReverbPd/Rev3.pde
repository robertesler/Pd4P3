
/*
This class emulates Pure Data’s rev3~ reverberator.
It uses 4 early‑reflection delay lines followed by a 16‑delay 
feedback network mixed through a stable, normalized 5-layer Hadamard matrix.

The reverb tail is shaped by a two‑stage damping system:
Primary damping: low‑pass filters on the first 4 delay lines
Secondary damping: gentle high‑frequency loss on the remaining 12 lines

Both stages use a smooth damping coefficient controlled by the user

Reverb time (RT60) is controlled by a nonlinear liveness curve, 
giving smooth control from short to long tails while maintaining 
stability in double precision.

User parameters
output level: 0–100
liveness: 0–100 (mapped through a power curve to feedback gain)
crossover frequency: 0–Nyquist (sets damping filter cutoff)
damping: 0–100% (controls HF decay rate)
*/

class Rev3 {
  
  private double outputLevel = 0;
  private double liveness = 0;
  private double crossover = 3000;
  private double damping = 0;
  VariableDelay [] delEarly = new VariableDelay[4];
  VariableDelay [] delay = new VariableDelay[16];
  LowPass [] lop = new LowPass[16];
  Notch [] notch = new Notch[4];
  Line line0 = new Line();
  Line line1 = new Line();
  Line line2 = new Line();
  Noise noiseL = new Noise();
  Noise noiseR = new Noise();
  private double [] earlyDelTime = {1.42763, 3.23873,5.2345, 7.82312};
  private double [] delTime = {10,11.6356, 13.4567, 16.7345, 20.1862, 25.7417, 31.4693, 38.2944,
                        46.6838, 55.4567, 65.1755, 76.8243, 88.5623, 101.278, 115.397, 130.502};
  private double [] early = new double[4];
  private double [] del = new double[16];
  
  public Rev3() {
    
    for(int i = 0; i < delEarly.length; i++)
    {
        delEarly[i] = new VariableDelay();
        early[i] = 0;
        notch[i] = new Notch();
        notch[i].setCenterFrequency(300);
        notch[i].setQ(3);
    }
    
     for(int i = 0; i < delay.length; i++)
    {
        delay[i] = new VariableDelay();
        del[i] = 0;
        lop[i] = new LowPass();
        lop[i].setCutoff(10000);
    }
    
  }
  
  //returns four outputs, the last four delays in the matrix
  public double [] perform(double inputL, double inputR)  {
    double [] output = new double[4];
    double [] earlyReflections = new double[2];
    
    //early reflections
    earlyReflections = computeEarly(inputL, inputR);
    double nLeft = noiseL.perform() * 1e-07;
    double nRight = noiseR.perform() * 1e-07;
    output = doit(earlyReflections[0] + nLeft, 
                  earlyReflections[1] + nRight);
    double vol = line0.perform(line0.dbtorms(outputLevel), 30);
    vol = Math.min(vol, .999);
    /*
    Our reverberator has a resonant frequency of around
    300Hz so we notch that out a little so we don't get
    any distortion in our system.
    */
    output[0] = notch[0].perform(output[0]) * vol;
    output[1] = notch[1].perform(output[1]) * vol;
    output[2] = notch[2].perform(output[2]) * vol;
    output[3] = notch[3].perform(output[3]) * vol;
    return output;
  }
  
  private double [] doit(double inputL, double inputR) {
     
    double [] output = new double[4];
    
     //we write to our delay line
    for(int i = 0; i < delay.length; i++)
    {
       delay[i].delayWrite(del[i]); 
    }
    
    //layer 1, damping
    double [] damp = new double[4];
    double target = Math.pow(damping / 100.0, 2.0);
    double kDamping = line1.perform(target, 50);
    kDamping = Math.min(kDamping, 1.0);
    for(int i = 0; i < delay.length/4; i++)
    {
       double a = delay[i].perform(delTime[i]);
       double b = lop[i].perform(a);
       double c = b - a;
       double d = c * kDamping;
       damp[i] = a + d;
    }
    
    //add our input to the signal chains
    double x = line2.perform(liveness/100, 35);
    double fb = 1.0 - Math.pow(1.0 - x, 1.3);
    fb = Math.min(fb, 0.999);
    del[0] = (damp[0] + inputL);
    del[1] = (damp[1] + inputR);
    del[2] = damp[2];
    del[3] = damp[3];
    
    //add general low pass on remaining delay lines
    for(int i = 4; i < delay.length - 4; i++)
    {
      double a = delay[i].perform(delTime[i]);
      double b = lop[i].perform(a);
      double c = b - a;
      double d = c * (kDamping * .1);
      del[i] = a + d;
    }
    
    //layer 2, mixing every other del
    for(int i = 0; i < delay.length; i += 2)
    {
      //double fb = line2.perform(liveness/400, 35);
      double a = del[i] * fb;
      double b = del[i+1] * fb;
      del[i] = (a + b);
      del[i+1] = (a - b);   
    }
    //layer 3, mix 1 with 3, 2 with 4
    for(int i = 0; i < delay.length; i += 4)
    {
       double a = del[i];
       double b = del[i+1];
       double c = del[i+2];
       double d = del[i+3];
       del[i] = (a + c);
       del[i+1] = (b + d);
       del[i+2] = (a - c);
       del[i+3] = (b - d);
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
       del[i] = (a + e);
       del[i+1] = (b + f);
       del[i+2] = (c + g);
       del[i+3] = (d + h);
       del[i+4] = (a - e);
       del[i+5] = (b - f);
       del[i+6] = (c - g);
       del[i+7] = (d - h);
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
       del[0] = (a + i) * .25;
       del[1] = (b + j) * .25;
       del[2] = (c + k) * .25;
       del[3] = (d + l) * .25;
       del[4] = (e + m) * .25;
       del[5] = (f + n) * .25;
       del[6] = (g + o) * .25;
       del[7] = (h + p) * .25;
       del[8] = (a - i) * .25;
       del[9] = (b - j) * .25;
       del[10] = (c - k) * .25;
       del[11] = (d - l) * .25;
       del[12] = (e - m) * .25;
       del[13] = (f - n) * .25;
       del[14] = (g - o) * .25;
       del[15] = (h - p) * .25;
    
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
    //The crossover point only applies to the first 4 lop
    for(int i = 0; i < lop.length/4; i++)
    {
      lop[i].setCutoff(crossover);
    }
    
    for(int i = 4; i < lop.length-4; i++)
    {
      lop[i].setCutoff(crossover * 2);
    }
    
  }
  
  private double [] computeEarly(double inputL, double inputR) {
      double [] output = new double[2];
      
      double x = inputR;
      double y = inputL;
      
      delEarly[0].delayWrite(x);
      early[0] = delEarly[0].perform(earlyDelTime[0]);
      double a = y - early[0];
      double b = y + early[0];
      
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
    Noise.free(noiseL);
    Noise.free(noiseR);
    
    for(int i = 0; i < delEarly.length; i++)
    {
        VariableDelay.free(delEarly[i]);
        notch[i].free();
    }
    
    for(int i = 0; i < delay.length; i++)
    {
        VariableDelay.free(delay[i]);
        LowPass.free(lop[i]);
    }
    
  }
  
}
