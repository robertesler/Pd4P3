/*
This class models the 3-pole, 3-zero Butterworth filter lp/hp/shelving from Pure Data's example
H13.butterworth.pd.  

For low pass set the high pass to >= SR/2 and normal to 0
For high pass set the low pass to 0 and normal to 1
For a shelving filter HP and LP specify the shelving band

We will use this in other examples as well, especially when we go over 
anti-aliasing sawtooth waves.

*/

class Butterworth {
 
  //our coefficients, see setButterworthCoef() for how those are calculated
  double [] lowPassCoefs = new double[6];
  double [] highPassCoefs = new double[6];
  int oversample = 1; //We will use this later when we are up or down sampling
  
  //Our unit generator
  Phasor phasor = new Phasor();
  
  //our raw filters
  RealPole rpole = new RealPole();
  ComplexPole cpole1 = new ComplexPole();
  ComplexPole cpole2 = new ComplexPole();
  RealZero rzero = new RealZero();
  ComplexZero czero1 = new ComplexZero();
  ComplexZero czero2 = new ComplexZero();
  
  RealZero rzero1 = new RealZero();
  RealZero rzero2 = new RealZero();
  
  public Butterworth(double lop, double hip, double normal, int oversamp)
  {
    oversample = oversamp;
    this.setLowPass(lop, normal);
    this.setHighPass(hip, normal);
  }
  
  double perform(double input) 
  {
    //low pass stage
     double a = rpole.perform(input * lowPassCoefs[0], lowPassCoefs[2]) * lowPassCoefs[1];
     double [] b = cpole1.perform(a, 0, lowPassCoefs[3], lowPassCoefs[4]);
     double [] c = cpole2.perform(b[0], b[1], lowPassCoefs[3], lowPassCoefs[5]);
     // high pass stage
     double d = rzero.perform(c[0] / (highPassCoefs[0]), highPassCoefs[2]) / highPassCoefs[1];
     double [] e = czero1.perform(d, 0, highPassCoefs[3], highPassCoefs[4]);
     double [] f = czero2.perform(e[0], e[1], highPassCoefs[3], highPassCoefs[5]);
    
     return f[0];
  }
  
  double [] butterworthCoef(double freq, double normalize) 
  {
    //convert our frequency first
    double sr = rpole.getSampleRate();
    double f = (freq / (sr*.5) ) / oversample; 
    //This theta in units of pi/2
    double [] coefs = new double[6];
    double theta = .667 * 1.5708;
    double a = tan((float)f * 1.5708);
    double b = (1 - a*a) / (1 + a*a + 2*a*cos((float)theta));
    double c = (2 * a*sin((float)theta)) / (1 + a*a + 2*a*cos((float)theta));
    coefs[5] = c * -1; //imag2b
    coefs[4] = c;//imag2a
    coefs[3] = b; //real2
    double d = (1 - a*a) / (1 + a*a + 2*a*cos(0));
    coefs[2] = d;//real1
    double normal = 1 - 2*normalize;
    double e = (b - normal) * (b - normal) + c*c;
    coefs[1] = e; //normalizer2
    coefs[0] = abs((float)(normal - d));//normalizer1
    return coefs;
    
  }
  
  void setLowPass(double freq, double norm) {
      lowPassCoefs = butterworthCoef(freq, norm);
  }
  
  void setHighPass(double freq, double norm) {
      highPassCoefs = butterworthCoef(freq, norm);
  }
  
  double [] getLowPass()
  {
     return lowPassCoefs; 
  }
  
  double [] getHighPass()
  {
    return highPassCoefs;  
  }
  
  void free() 
  {
    RealPole.free(rpole);
    ComplexPole.free(cpole1);
    ComplexPole.free(cpole2);
    RealZero.free(rzero);
    ComplexZero.free(czero1);
    ComplexZero.free(czero2);
    RealZero.free(rzero1);
    RealZero.free(rzero2);
  }
  
}
