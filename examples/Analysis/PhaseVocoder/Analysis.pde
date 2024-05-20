/*
This is a sample-based phase vocoder.
It is based on the Pd example: I07.phase.vocoder.pd
by Miller Puckette.

If you change the location, then reset speed to 0
If you use auto, then set rewind to true update speed to auto's value.

*/

class Analysis extends PdMaster {
  
   rFFT rfft;
   rFFT rfft2;
   rIFFT rifft;
   Oscillator osc = new Oscillator();
   Line line = new Line();
   LRShift [] lrshift = new LRShift[4];
   TabRead4 tab1 =  new TabRead4();
   TabRead4 tab2 =  new TabRead4();
   SoundFiler soundfiler = new SoundFiler();
   double[] hann;
   double[] prevReal;
   double[] prevImag;
   double[] fft1;
   double[] fft2;
   double[] real1;
   double[] imag1;
   double[] real2;
   double[] imag2;
   double[] neighbor1;
   double[] neighbor2;
   double[] phaseVocoder;
   double[] ifft;
   double[] sample; //our sample table
   double index1 = 0;
   double index2 = 0;
   int hannIndex = 0;
   ArrayList<Double> buffer;
   double location = 0;
   double speed = 0;
   boolean rewind = true;
   int auto = 100;
   double transpo = 0;
   int lock = 0;
   int currentWindowSize = fftWindowSize;
  
  
   Analysis()  {
      
      rfft = new rFFT(fftWindowSize);
      rifft = new rIFFT(fftWindowSize);
      rfft2  = new rFFT(fftWindowSize);
      hann = new double[fftWindowSize];
      prevReal = new double[fftWindowSize];
      prevImag = new double[fftWindowSize];
      fft1 = new double[fftWindowSize];
      fft2 = new double[fftWindowSize];
      real1 = new double[fftWindowSize];
      imag1 = new double[fftWindowSize];
      real2 = new double[fftWindowSize];
      imag2 = new double[fftWindowSize];
      neighbor1 =new double[fftWindowSize];
      neighbor2 = new double[fftWindowSize];
      phaseVocoder = new double[fftWindowSize];
      ifft = new double[fftWindowSize];
      tab1.setTable(sample);
      tab2.setTable(sample);
      createHann(fftWindowSize);
      
      for(int i = 0; i < 4; i++)
      {
        lrshift[i] = new LRShift(); 
      }
     
   }
   
   double perform() {
    
     return 0;
   }
   
   double[] doFFT() {
     double magReal = 0;
     double magImag = 0;
     double magReal2 = 0;
     double magImag2 = 0;
     
     //recall previous output amplitude, real/imag
     for(int i = 0; i < prevReal.length; i++)
     {
        double r = prevReal[i];
        double j = prevImag[i];
        double mag = rsqrt((r*r) + (j*j)+1e-20);
        magReal = r * mag;
        magImag = j * mag;
     }
     
    //do our fft on our two windows
    for(int i = 0; i < fftWindowSize; i++)
    {
       double [] readWin = readWindows();
       fft1 = rfft.perform(readWin[0]);
       fft2 = rfft2.perform(readWin[1]);
    }
    
    //get real and imaginary parts
    for(int i = 0, j = fftWindowSize-1; i < fftWindowSize/2; i++, j--)
    {
       real1[i] = fft1[i];
       imag1[i] = fft1[j]; 
       real2[i] = fft2[i];
       imag2[i] = fft2[j]; 
    }
    
    //calculate conjugates
    for(int i = 0 ; i < fftWindowSize; i++)
    {
        double a = magReal * real1[i];
        double b = magImag * imag1[i];
        double c = magImag * real1[i];
        double d = magReal * imag1[i];
        neighbor1[i] = a + b;
        neighbor2[i] = c - d;
    }
    
    //shift our neighboring bins 
    double[] shiftA = lrshift[0].perform(neighbor1, 1);
    double[] shiftB = lrshift[1].perform(neighbor1, -1);
    double[] shiftC = lrshift[2].perform(neighbor2, 1);
    double[] shiftD = lrshift[3].perform(neighbor2, -1);
     
    //
    for(int i = 0; i < fftWindowSize; i++)
    {
        double x = ((shiftA[i] + shiftB[i])*lock) + neighbor1[i] + 1e-15;
        double y = ((shiftC[i] + shiftD[i])*lock) + neighbor2[i];
        double mag = rsqrt((x*x) + (y*y));
        magReal2 = x * mag;
        magImag2 = y * mag;
        double a = magReal2 * real2[i];
        double b = magImag2 * imag2[i];
        double c = magReal2 * imag2[i];
        double d = magImag2 * real2[i];
        double e = a - b;
        double f = c + d;
        prevReal[i] = e;
        prevImag[i] = f;
    }
    
     //Let's put Humpty Dumpty back together again.
    for(int i = 0, j = fftWindowSize-1; i < fftWindowSize/2; i++, j--)
    {
        //send the switched values to rifft
        phaseVocoder[i] = prevReal[i];
        phaseVocoder[j] = prevImag[i];
    }

    //resynthesize our FFT block, multiply by our Hann window and normalizer
    for(int i = 0; i < fftWindowSize; i++)
    {
        ifft[i] = (rifft.perform(phaseVocoder)* hann[i]) * (2/(3*currentWindowSize));
    }
    
    return ifft; 
   }
   
   //read two windows out the recording, on 1/4 phase ahead of the other.
    double[] readWindows() {
      double[] output = {0,0};
      int windowSize = currentWindowSize;
      double window = ((windowSize/this.getSampleRate())*1000)/4;
      double stretchedWindowSize = windowSize * this.mtof((transpo * .01)+69)/440;
      double seeLoc = location + (window *speed * .01);
      double readLocation = seeLoc * (this.getSampleRate()/1000) - (stretchedWindowSize/2);
      tab1.setOnset(readLocation);
      tab2.setOnset(readLocation);
      
      if(rewind)
      {
       location = ((stretchedWindowSize/this.getSampleRate())*1000)*-.5;
       rewind = false;
      }
      
      if(index1 == stretchedWindowSize) 
      {
        index1 = 0;
        index2 = 0;
      }
      double x = line.perform(stretchedWindowSize, window);
      index1 = x - (stretchedWindowSize/4);
      index2 = x;
      if(hannIndex == hann.length) hannIndex = 0;
      output[0] = tab1.perform(index1) * hann[hannIndex];
      output[1] = tab2.perform(index2) * hann[hannIndex];
      hannIndex++;
      return output;
    }
   
    /*
    Reads our sample and writes to our sample table.
    */
    void inSample(String fileName) {
      soundfiler.read(fileName);
      sample = soundfiler.getArray();
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
 
//reciprocal sqrt
public double rsqrt(double x) {
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
  }
}
