/*
This class will analyze the signal just like we have before,
using an overlap of 4 and a decent window size.  But this time
we will use the LRShift class which shifts the bins left or right
and checks their coherence.  Then we resynthesize the whole lot
and control how much of the "clean" signal vs. the "dirty" signal.
This is called pitched/unpitched signal separation.  

This is based on Miller Puckette's Pd patch "Sheep from Goats".
*/

class Analysis extends PdMaster {

   rFFT rfft;
   rIFFT rifft;
   Oscillator osc = new Oscillator();
   LRShift [] lrshift = new LRShift[8];
   int overlap = 4;
   double[] fft;
   double[] hann;
   double[] sheep;
   double[] tempSheep;
   ArrayList<Double> buffer;
   double[] in;
   double[] sum;
   double[] ifft;
   double[] ifftWas;
   double[] tempReal;
   double[] tempImag;
   double[] tempClean;
   double[] tempDirty;
   long sampleCounter = 0;
   double clean = 0;
   double dirty = 0;
   float[] out = new float[overlap];
   
   Analysis() {
      this.setFFTWindow(2048); 

      rfft = new rFFT(this.getFFTWindow());
      rifft = new rIFFT(this.getFFTWindow());
      fft  = new double[this.getFFTWindow()];
      hann = new double[this.getFFTWindow()];
      sheep  = new double[this.getFFTWindow()];
      tempSheep = new double[this.getFFTWindow()];
      buffer = new ArrayList<Double>(this.getFFTWindow());
      in = new double[this.getFFTWindow()/overlap];
      sum = new double[this.getFFTWindow()];
      ifft = new double[this.getFFTWindow()];
      ifftWas = new double[this.getFFTWindow()];
      tempReal = new double[this.getFFTWindow()];
      tempImag = new double[this.getFFTWindow()];
      tempClean = new double[this.getFFTWindow()];
      tempDirty = new double[this.getFFTWindow()];
      createHann(this.getFFTWindow());
      
      for(int i = 0; i < 8; i++)
      {
        lrshift[i] = new LRShift(); 
      }
    
   }
  
  
  double perform(double input) {
    
    double out = doFFT(input);
    return out;
  }
  
  double doFFT(double filter) {
    
    int hop = this.getFFTWindow()/overlap;
    in[(int)sampleCounter] = filter;
    
    if(sampleCounter == hop-1)
    {
      for(int i = 0; i < hop; i++)
      {
       buffer.add(in[i]);
       buffer.remove(0); 
      }
  
      //Now we perform our FFTs and multiply by our Hann window
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
       fft = rfft.perform(buffer.get(i)*hann[i]);
      }
      
    /***********
    Our pitch/unpitched separation, get the magnitudes of the real and imag components
    ************/
    
      for(int i = 0, j = this.getFFTWindow()-1; i < this.getFFTWindow()/2; i++, j--)
      {
          double real = fft[i];
          double imag = fft[j];
          //sqrt( real^2 + imag^2) = freq bin magnitude
          double magnitude = rsqrt( ( (float)(real * real) + (float)(imag * imag) ) + 1e-020);
        
          tempReal[i] = magnitude * real;
          tempImag[i] = magnitude * imag;
      }
      
      //Let's get the total incoherence
      double[] r1 = lrshift[0].perform(tempReal, 1); 
      double[] r2 = lrshift[1].perform(tempReal, -1);
      double[] i1 = lrshift[2].perform(tempImag, 1); 
      double[] i2 = lrshift[3].perform(tempImag, -1);
   
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
         double a = r1[i] + tempReal[i];
         double b = r2[i] + tempReal[i];
         a *= a;
         b *= b;
         
         double c = i1[i] + tempImag[i];
         double d = i2[i] + tempImag[i];
         
         c *= c;
         d *= d;
         
         sheep[i] = a + b + c + d;

      }
      
      
      //Let's separate clean and dirty signals
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
          double cl = getClean();
          double a = (sheep[i] - ((cl*cl)/1250) ) * 1e+20;
          tempClean[i] = clip(a, 0, 1);
      }
      
      //Let's separate clean and dirty signals
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
          double d = getDirty();
          double a = (sheep[i] - ((d*d)/1250) ) * 1e+20;
          tempDirty[i] = clip(a, 0, 1);
      }

      double[] c1 = lrshift[4].perform(tempClean, 1);
      double[] c2 = lrshift[5].perform(tempClean, -1);
      double[] d1 = lrshift[6].perform(tempDirty, 1);
      double[] d2 = lrshift[7].perform(tempDirty, -1);
      
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
          double a = c1[i] * tempClean[i];
          double b = c2[i] * a;
          b = (b * -1) + 1;
         
          double c = d1[i] * tempDirty[i];
          double d = d2[i] * c;
          sheep[i] = (b + d) / this.getFFTWindow();
      }
      
       //Zero DC bin
      sheep[0] = 0;
     
      for(int i = 0, j = this.getFFTWindow()-1; i < this.getFFTWindow()/2; i++, j--)
      {  
         tempSheep[i] = sheep[i] * fft[i];
         tempSheep[j] = sheep[i] * fft[j];
      }
     
        /***********************************/
      
      
      //resynthesize our FFT block, multiply by our Hann window again
       for(int i = 0; i < this.getFFTWindow(); i++)
       {
        ifft[i] = rifft.perform(tempSheep)* hann[i];
       }
 
      // Now we overlap our windows, and add them together
      for(int i = 0 ; i < this.getFFTWindow(); i++)
      {
          sum[i] = ifft[i] + (i+hop < this.getFFTWindow() ? ifftWas[i+hop] : 0);
      }
      
      ifftWas = sum;
     
      sampleCounter = -1;
    }
    
    sampleCounter++;
    return  sum[(int)sampleCounter];

  }
  
  synchronized void setDirty(double d) {
     dirty = d; 
  }
  
  synchronized double getDirty() {
     return dirty; 
  }
  
  synchronized void setClean(double c) {
     clean = c; 
  }
  
  synchronized double getClean() {
     return clean; 
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
       for(int i = 0; i < this.getFFTWindow(); i++)
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
