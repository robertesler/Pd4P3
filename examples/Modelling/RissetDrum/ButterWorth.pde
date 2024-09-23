/*
This class is based on the Butterworth3~ pure data
abstraction.  It is an implementation of a 3-pole, 3-zero
butterworth lp/hp shelving filter.
This should provide an 18dB per octave shelf.
*/

class Butterworth extends PdMaster {
  
  RealPole rpole = new RealPole();
  ComplexPole cpole1 = new ComplexPole();
  ComplexPole cpole2 = new ComplexPole();
  RealZero rzero = new RealZero();
  ComplexZero czero1 = new ComplexZero();
  ComplexZero czero2 = new ComplexZero();
 
  public double perform(double input, double lp, double hp, int norm, boolean clear) {
    
    if(clear)
    {
      rpole.clear();
      cpole1.clear();
      cpole2.clear();
      rzero.clear();
      czero1.clear();
      czero2.clear();
    }
    
    double [] lop = buttercoef(lp, norm);
    double in = input * lop[0];
    double pole = rpole.perform(in, lop[2]) * lop[1]; //normalize the lp signal
    double [] cmplxPole1 = cpole1.perform(pole, 0, lop[3], lop[4]);
    double [] cmplxPole2 = cpole2.perform(cmplxPole1[0], cmplxPole1[1], lop[3], lop[5]);
    
    double [] hip = buttercoef(hp, norm);
    double in2 = cmplxPole2[0] / hip[0];
    double zero = rzero.perform(in2, hip[2]) / hip[1]; //normalize the hp signal;
    double [] cmplxZero1 = czero1.perform(zero, 0, hip[3], hip[4]);
    double [] cmplxZero2 = czero2.perform(cmplxZero1[0], cmplxZero1[1], hip[3], hip[5]);
    double output = cmplxZero2[0];
    return output; 
  }
  
  double [] buttercoef(double freq, int norm) {
    double [] butterPack = new double[6];
    
    freq = freq/(this.getSampleRate()*.5); //scale freq range to DC - Nyquist
    
    double tangent = tan((float)freq * 1.57);
    double theta = 1.0477236; //.667 *1.5708
    double real = (1 - (tangent*tangent)) / (1 + (tangent*tangent) + (2*tangent*cos((float)theta)));
    double imag = (2*tangent*sin((float)theta)) / (1 + (tangent*tangent) + (2*tangent*cos((float)theta)));
    double realZeroTheta = (1 - (tangent*tangent)) / (1 + (tangent*tangent) + (2*tangent*cos(0)));
    double normalize = 1 - (2*norm);
    double normalizer1 = abs((float)(normalize - realZeroTheta));
    double normalizer2 = ( (real - normalize) * (real - normalize) + (imag*imag) );
    double real1 = realZeroTheta;
    double real2 = real;
    double imag2a = imag;
    double imag2b = imag * -1;
    
    butterPack[0] = normalizer1;
    butterPack[1] = normalizer2;
    butterPack[2] = real1;
    butterPack[3] = real2;
    butterPack[4] = imag2a;
    butterPack[5] = imag2b;
    return butterPack;
  }
  
  public void free() {
    RealPole.free(rpole);
    ComplexPole.free(cpole1);
    ComplexPole.free(cpole2);
    RealZero.free(rzero);
    ComplexZero.free(czero1);
    ComplexZero.free(czero2);
  }
}
