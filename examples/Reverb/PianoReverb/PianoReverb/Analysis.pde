/*
 

This is based on Miller Puckette's Pd patch "Piano Reverb".
*/

class Analysis extends PdMaster {

   rFFT rfft;
   rIFFT rifft;
   Oscillator osc = new Oscillator();
   LRShift lrshift1 = new LRShift();
   LRShift lrshift2 = new LRShift();
   
   int overlap = 4;
   double[] fft;
   double[] hann;
   double[] decision;
   double[] previous;
   double [] abc;
   double [] switchA;
   double [] switchB;
   double [] switchC;
   double [] switchD;
   double [] divideByPrevA;
   double [] divideByPrevB;
   double[] pianoRev;
   ArrayList<Double> buffer;
   double[] in;
   double[] sum;
   double[] ifft;
   double[] ifftWas;
   double[] ampReal;
   double[] ampImag;
   double[] incReal;
   double[] incImag;
   double[] real;
   double[] imag;
   double[] lastReal;
   double[] lastImag;
   long sampleCounter = 0;
   double time = 0;
   float[] out = new float[overlap];
   
   Analysis() {
      this.setFFTWindow(fftWindowSize); 

      rfft = new rFFT(fftWindowSize);
      rifft = new rIFFT(fftWindowSize);
      fft  = new double[fftWindowSize];
      hann = new double[fftWindowSize];
      decision  = new double[fftWindowSize];
      previous = new double[fftWindowSize];
      pianoRev = new double[fftWindowSize];
      abc = new double[fftWindowSize];
      switchA = new double[fftWindowSize];
      switchB = new double[fftWindowSize];
      switchC = new double[fftWindowSize];
      switchD = new double[fftWindowSize];
      divideByPrevA = new double[fftWindowSize];
      divideByPrevB = new double[fftWindowSize];
      buffer = new ArrayList<Double>(fftWindowSize);
      in = new double[fftWindowSize/overlap];
      sum = new double[fftWindowSize];
      ifft = new double[fftWindowSize];
      ifftWas = new double[fftWindowSize];
      ampReal = new double[fftWindowSize];
      ampImag = new double[fftWindowSize];
      incReal = new double[fftWindowSize];
      incImag = new double[fftWindowSize];
      real = new double[fftWindowSize];
      imag = new double[fftWindowSize];
      lastReal = new double[fftWindowSize];
      lastImag = new double[fftWindowSize];
      createHann(fftWindowSize);
     
    
   }
  
  
  double perform(double input) {
    
    double out = doFFT(input);
    return out;
  }
  
  double doFFT(double filter) {
    
    int hop = fftWindowSize/overlap;
    in[(int)sampleCounter] = filter;
    
    if(sampleCounter == hop-1)
    {
      for(int i = 0; i < hop; i++)
      {
       buffer.add(in[i]);
       buffer.remove(0); 
      }
  
      //Now we perform our FFT and multiply by our Hann window
      for(int i = 0; i < fftWindowSize; i++)
      {
       fft = rfft.perform(buffer.get(i)*hann[i]);
      }
      
      //Get the real and imaginary parts
      for(int i = 0, j = fftWindowSize-1; i < fftWindowSize/2; i++, j--)
      {
          real[i] = fft[i];
          imag[i] = fft[j]; 
      }
      
 /*****************BEGINNING of Analysis************/
      
      //Step 1: get magnitude of each bin, get previous amplitude of real/imag
      for(int i = 0; i < fftWindowSize; i++)
       {
          double r = real[i];
          double im = imag[i];
          //sqrt( real^2 + imag^2) = freq bin magnitude
          double magnitude = (r * r) + (im * im);
          double ar = ampReal[i] + 1e-015;
          double ai = ampImag[i];
          double pr = (ar*ar) + (ai*ai);
          decision[i] = magnitude;//new
          previous[i] = pr;//old
          
          //divide by previous phase
          double a = lastReal[i] * r;
          double b = lastImag[i] * im;
          double c = lastReal[i] * im;
          double d = lastImag[i] * r;
          divideByPrevA[i] = a + b;
          divideByPrevB[i] = c - d;
          lastReal[i] = r;
          lastImag[i] = im;
       }
      
      double [] shiftA = lrshift1.perform(decision, 1);
      double [] shiftB = lrshift2.perform(decision, -1);
     
      //Choose whether to "punch" in a new amp/inc pair, aka decision
      for(int i = 0; i < fftWindowSize; i++)
       {
           double a = (decision[i] - previous[i]) * 1e+020;
           a = clip(a, 0, 1);
           
           double b = (decision[i] - shiftA[i]) * 1e+020;
           b = clip(b, 0, 1);
           
           double c = (decision[i] - shiftB[i]) * 1e+020;
           c = clip(c, 0, 1);
           
           abc[i] = a * b * c;
       }
       
      //Switch between pairs of inputs
      for(int i = 0; i < fftWindowSize; i++)
      {
         //switch1
          double r = real[i];
          double im = imag[i];
          double ar = ampReal[i] + 1e-015;
          double ai = ampImag[i];
          
          double a = ((r - ar) * abc[i]) + ar;
          double b = ((im - ai) * abc[i]) + ai;
          switchA[i] = a;
          switchB[i] = b;
          
          //switch2
          double ir = incReal[i] + 1e-015;
          double c = ((divideByPrevA[i] - ir) * abc[i]) + ir;
          double d = ((divideByPrevB[i] - incImag[i]) * abc[i]) + incImag[i];
          switchC[i] = c;
          switchD[i] = d;
          
          //set tables
          double x = (switchC[i] * switchC[i]) + (switchD[i] * switchD[i]);
          double y = (rsqrt((float)x) * getTime());
          incImag[i] = y * switchD[i]; 
          incReal[i] = switchC[i] * y;
          ampImag[i] = (incReal[i] * switchB[i]) + (incImag[i] * switchA[i]);
          ampReal[i] = (incReal[i] * switchA[i]) - (incImag[i] * switchB[i]);
          
          
       }
       
       //Let's put Humpty Dumpty back together again.
       for(int i = 0, j = fftWindowSize-1; i < fftWindowSize/2; i++, j--)
      {
        //send the switched values to rifft
          pianoRev[i] = switchA[i];
          pianoRev[j] = switchB[i];
      }
     
 /*****************END of Analysis******************/
      
      
      //resynthesize our FFT block, multiply by our Hann window and normalizer
       for(int i = 0; i < fftWindowSize; i++)
       {
        ifft[i] = (rifft.perform(pianoRev)* hann[i]) / (fftWindowSize*4);
       }
 
      // Now we overlap our windows, and add them together
      for(int i = 0 ; i < fftWindowSize; i++)
      {
          sum[i] = ifft[i] + (i+hop < fftWindowSize ? ifftWas[i+hop] : 0);
      }
      
      ifftWas = sum;
     
      sampleCounter = -1;
    }
    
    sampleCounter++;
    return  sum[(int)sampleCounter];

  }
  
  synchronized void setTime(double t) {
     time = 1 - (.2/max(.2, (float)t)); 
  }
  
  synchronized double getTime() {
     return time; 
  }
  
   /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann(int ws) {
     
     double winHz = 0;
     int windowSize = ws;
   //clear our buffer first thing, it only does this once
   if(buffer.size() == 0)
    {
      double d= 0;
       for(int i = 0; i < fftWindowSize; i++)
       {
         buffer.add(d);
       }
    }
     
     if(windowSize != 0) {
        winHz = this.getSampleRate()/windowSize;
     }
     else {
       windowSize = 32;
       println("Window size cannot be zero!");
     }

     osc.setPhase(0);     
     for(int i = 0; i < windowSize; i++)
      {
        hann[i] = (osc.perform(winHz)* -.5) + .5;
      }
       
 }
 
  //emulate [clip~], a = input, b = low range, c = high range
   private double clip(double a, double b, double c) {
     if(a < b)
       return b;
      else if(a > c)
       return c;
      else
        return a;
   }
  
    //inverse sqrt
public float rsqrt(float x) {
    float xhalf = 0.5f * x;
    int i = Float.floatToIntBits(x);
    i = 0x5f3759df - (i >> 1);
    x = Float.intBitsToFloat(i);
    x *= (1.5f - xhalf * x * x);
    return x;
}
  
  void free() {
    rFFT.free(rfft);
    rIFFT.free(rifft);
    Oscillator.free(osc);
  }
  
}
