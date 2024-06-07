/*
This is a sample-based phase vocoder.
It is based on the Pd example: I07.phase.vocoder.pd
by Miller Puckette.

This class was far too slow my PC, it may work on yours.
So it is also included as a C++ function with the
dynamic library. 

This is what the example is actually using to render the audio.

*/

class PhaseVocoder2 extends PdMaster {
  
      rFFT rfft;
      rFFT rfft2;
      rIFFT rifft;
      Oscillator osc = new Oscillator();
      TabRead4 tab1 = new TabRead4();
      TabRead4 tab2 = new TabRead4();
      Line line = new Line();
      SoundFiler soundfiler = new SoundFiler();
      LRShift lrshiftA = new LRShift();
      LRShift lrshiftB = new LRShift();
      LRShift lrshiftC = new LRShift();
      LRShift lrshiftD = new LRShift();
      
      double[] hann;
      double[] ifftWas;
      double[] tmp;
      double[] real1;
      double[] real2;
      double[] imag1;
      double[] imag2;
      double[] prevReal;
      double[] prevImag;
      double[] neighbor1;
      double[] neighbor2;
      double[] phaseVocoder;
      double[] ifft;
      
      double[] sample; //our sample table
      double index1 = 0;
      double index2 = 0;
      double location = 0;
      double seeLoc = 0;
      double speed = 100;
      boolean rewind = true;
      double transpo = 100;
      int lock = 1;
      int currentWindowSize;
      int sampleCounter = 0;
      int loopCounter = 0;
      double readLocation = 0;
      int blockCounter = 0;
      long sampleSize = 0;
      int overlap = 4;
      boolean bang = false;

  
  
   PhaseVocoder2()  {
      this.setFFTWindow(fftWindowSize);
      rfft = new rFFT(fftWindowSize);
      rifft = new rIFFT(fftWindowSize);
      rfft2  = new rFFT(fftWindowSize);
      hann = new double[fftWindowSize];
      prevReal = new double[fftWindowSize];
      prevImag = new double[fftWindowSize];
      real1 = new double[fftWindowSize];
      imag1 = new double[fftWindowSize];
      real2 = new double[fftWindowSize];
      imag2 = new double[fftWindowSize];
      neighbor1 =new double[fftWindowSize];
      neighbor2 = new double[fftWindowSize];
      phaseVocoder = new double[fftWindowSize];
      ifft = new double[fftWindowSize];
      ifftWas = new double[fftWindowSize];
      createHann(fftWindowSize);
      
   }
   
   void setSpeed(double s) {
      speed = s;
   }
   
   void setTranspo(double t) {
     transpo = t;  
   }
   
   void rewind() {
     rewind = true;
   }
   
   double perform() {

     return doFFT();
   }
   
   private double doFFT() {
     
    int ws = this.getFFTWindow();
    int hop = this.getFFTWindow() / overlap;
    double[] sum = ifftWas;
     
    if(sampleCounter == hop-1)
    {
      double[] fft1 = new double[this.getFFTWindow()];
      double[] fft2 =  new double[this.getFFTWindow()];
      bang = true;
      
      for(int i = 0; i < fftWindowSize; i++)
      {
         double[] out = readWindows();
         bang = false;
         fft1 = rfft.perform(out[0]*hann[i]);
         fft2 = rfft2.perform(out[1]*hann[i]);
      }
     
    /********************* BEGINNING of Analysis *******************/
    
    for (int i = 0, j = this.getFFTWindow() - 1; i < this.getFFTWindow() / 2; i++, j--)
      {
        real1[i] = fft1[i];
        imag1[i] = fft1[j];
        real2[i] = fft2[i];
        imag2[i] = fft2[j];
      }

      /********************* BEGINNING of Analysis *******************/

      for (int i = 0; i < this.getFFTWindow(); i++)
      {
        //recall previous output amplitude, real/imag
        double p_r = prevReal[i];
        double p_i = prevImag[i];
        double mag = rsqrt((p_r * p_r) + (p_i * p_i) + 1e-20);
        double magReal = p_r * mag;
        double magImag = p_i * mag;


        //calculate conjugates
        double a = magReal * real1[i];
        double b = magImag * imag1[i];
        double c = magImag * real1[i];
        double d = magReal * imag1[i];
        neighbor1[i] = a + b;
        neighbor2[i] = c - d;
      }

      //shift our neighboring bins 
      double[] shiftA = lrshiftA.perform(neighbor1, 1);
      double[] shiftB = lrshiftB.perform(neighbor1, -1);
      double[] shiftC = lrshiftC.perform(neighbor2, 1);
      double[] shiftD = lrshiftD.perform(neighbor2, -1);
      
    
      //take the previous fft of the forward window, and store in our prevReal/prevImag arrays
      for (int i = 0; i < this.getFFTWindow(); i++)
      {
        double x = ((shiftA[i] + shiftB[i]) * lock) + neighbor1[i] + 1e-15;
        double y = ((shiftC[i] + shiftD[i]) * lock) + neighbor2[i];
        double mag = rsqrt((x * x) + (y * y));
        double magReal = x * mag;
        double magImag = y * mag;
      
        double a = magReal * real2[i];
        double b = magImag * imag2[i];
        double c = magReal * imag2[i];
        double d = magImag * real2[i];
        double e = a - b;
        double f = c + d;
        prevReal[i] = e;
        prevImag[i] = f;
      }
    
      for (int i = 0, j = this.getFFTWindow() - 1; i < this.getFFTWindow() / 2; i++, j--)
      {
        phaseVocoder[i] = prevReal[i];
        phaseVocoder[j] = prevImag[i];
      }

    /********************* END of Analysis *******************/

      //resynthesize our FFT block, multiply by our Hann window
      for (int i = 0; i < this.getFFTWindow(); i++)
      {
        ifft[i] = (rifft.perform(phaseVocoder) * hann[i]);
      }

      // Now we overlap our windows, and add them together
      for (int i = 0; i < fftWindowSize; i++)
      {
        sum[i] = ifft[i] + (i + hop < currentWindowSize ? ifftWas[i + hop] : 0);
      }

      ifftWas = sum;
      sampleCounter = -1;
    }

    sampleCounter++;
    //return a each sample from our previous block * our normalizer
    return  sum[sampleCounter] / (currentWindowSize*3);
  }
   
   //read two windows out the recording, one 1/4 phase ahead of the other.
   private double[] readWindows() {
    double[] output = { 0,0 };
    int windowSize = currentWindowSize;
    double window = (((float)windowSize / this.getSampleRate()) * 1000);
    double stretchedWindowSize = windowSize * this.mtof((transpo * .01) + 69) / 440;
    blockCounter++;
    //double x = blockCounter * (stretchedWindowSize / windowSize);
    double y = line.perform(stretchedWindowSize, window);
    

    //update the read location every fft block
    if (bang)
    {
      seeLoc = location + (window * (speed/4 ) * .01);
      readLocation = (location * (this.getSampleRate() / 1000)) - (stretchedWindowSize / 2);
      location = seeLoc;
      tab1.setOnset(readLocation);
      tab2.setOnset(readLocation);
      line.perform(0, 0);
      blockCounter = 0;
    }

    //if we rewind reset location.
    if (rewind)
    {
      location = ((stretchedWindowSize / this.getSampleRate()) * 1000) * -.5;
      rewind = false;
    }

    //read through one block of our sample, with tab1 being 1/4 cycle behind
    index1 = y - (stretchedWindowSize / 4.);
    index2 = y;

    output[0] = tab1.perform(index1);
    output[1] = tab2.perform(index2);
    return output;

    }
   
    /*
    Reads our sample and writes to our sample table.
    */
    void inSample(String fileName) {
      soundfiler.read(fileName);
      sample = soundfiler.getArray();
      tab1.setTable(sample);
      tab2.setTable(sample);
    }
   
    /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann(int ws) {
     
     double winHz = 0;
     int windowSize = ws;
     
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
 
  //reciprocal sqrt
  private double rsqrt(double x) {
    double xhalf = 0.5f * x;
    long i = Double.doubleToLongBits(x);
    i = 0x5f3759df - (i >> 1);
    x = Double.longBitsToDouble(i);
    x *= (1.5f - xhalf * x * x);
    return x;
  }
  
  void free() {
    rFFT.free(rfft);
    rFFT.free(rfft2);
    rIFFT.free(rifft);
    TabRead4.free(tab1);
    TabRead4.free(tab2);
    Oscillator.free(osc);
    Line.free(line);
    SoundFiler.free(soundfiler);
  }
}
