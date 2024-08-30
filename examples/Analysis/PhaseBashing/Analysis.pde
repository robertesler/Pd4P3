class Analysis extends PdMaster {
 
   rFFT rfft = new rFFT(fftWindowSize);
   rIFFT rifft = new rIFFT(fftWindowSize);
   Oscillator osc = new Oscillator();
   Oscillator osc2 = new Oscillator();
   SoundFiler soundfiler = new SoundFiler();
   int overlap = 2;
   double[] fft  = new double[fftWindowSize];
   double[] hann = new double[fftWindowSize];
   ArrayList<Double> buffer = new ArrayList<Double>(fftWindowSize);
   double[] in = new double[fftWindowSize/overlap];
   double[] sum = new double[fftWindowSize];
   double[] ifft = new double[fftWindowSize];
   double[] ifftWas = new double[fftWindowSize];
   double[] filter = new double[fftWindowSize/2];
   double[] bins = new double[fftWindowSize];
   double[] phaseCtrl = new double[fftWindowSize];
   double[] sample;
   double[] nophase;
   long sampleCounter = 0;
   int phaseCounter = 0;
   int tableCounter = 0;
   boolean bang = false;
   int windowSize = fftWindowSize;
   
   public Analysis() {
     createHann();
     osc2.setPhase(0);
   }
     
  double doFFT(double input) {
    
    int hop = fftWindowSize/overlap;
    in[(int)sampleCounter] = input;
 
    /* now for every overlap, or hop size, add our input to the end
      of the buffer.  This will add x new samples and reuse the 
      windowsize-x previous samples.  This is our overlap buffer.
    */
    
    if(sampleCounter == hop-1)
    {
      //update our buffer
      for(int i = 0; i < hop; i++)
      {
         buffer.add(in[i]);
         buffer.remove(0); 
      }
      
      //Now we perform our FFT and multiply by our Hann window
      for(int i = 0; i < fftWindowSize; i++)
        fft = rfft.perform(buffer.get(i)*hann[i]);
      
      /*
      do something with our frequency bins here
      Remember with rFFT the first half of the array is real
      the back half is imaginary.
      In this example we are just applying a very broad linear band filter.
      */
      for(int i = 0, j = fftWindowSize-1; i < fftWindowSize/2; i++, j--)
      {
           
          double real = fft[i];
          double imag = fft[j];
          //sqrt( real^2 + imag^2) = freq bin magnitude
         float magnitude = sqrt( (float)(real * real) + (float)(imag * imag) );
         
          phaseCtrl[i] = (magnitude * controlOsc())/windowSize;
          
      }
      
      //resynthesize our FFT block, multiply by our Hann window again
       for(int i = 0; i < fftWindowSize; i++)
       {
         ifft[i] = rifft.perform(phaseCtrl) * hann[i];
       }
       
      //our overlapping
      for(int i = 0 ; i < fftWindowSize; i++)
        sum[i] = ifft[i] + (i+hop < fftWindowSize ? ifftWas[i+hop] : 0);
        
      ifftWas = sum;
       
      sampleCounter = -1;
    }
    
    sampleCounter++;
   return  sum[(int)sampleCounter];
  
  }
  
  private double controlOsc() {
      double out = 0;
      phaseCounter++;
      if(phaseCounter == windowSize) 
      {
        osc2.setPhase(0);
        phaseCounter = 0;
      }
      out = osc2.perform(this.getSampleRate());
      return out;
  }
  
  void createTable(String file) {
    soundfiler.read(file);
    sample = soundfiler.getArray();
    nophase = new double[sample.length];
     /*
    Set a delay of one frame (windowSize/overlap) minus 1.
    This synchronize our nophase table with our analysis window.
    */
    double del = (windowSize/overlap) - 1;
    for(int i = 0; i < nophase.length; i++)
    {
      double d = doFFT(sample[i]);
      if(i >= del)
      {
        nophase[i] = d;
        //if(d > .9)
         // println(d);
      }
      
    }
  }
   
   double [] getTable() {
      return nophase; 
   }
   
   int getWindowSize() {
      return windowSize; 
   }
   //Hanning Window
   private void createHann() {
    
     double winHz = 0;
     int windowSize = fftWindowSize;
    
    //clear our buffer first thing, it only does this once
     if(buffer.size() == 0)
     {
        double d= 0;
        for(int i = 0; i < fftWindowSize; i++)
          buffer.add(d);
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
        hann[i] = ((osc.perform(winHz)* -.5) + .5);
     }
     
 }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     rFFT.free(rfft);
     rIFFT.free(rifft);
     Oscillator.free(osc);
     Oscillator.free(osc2);
     SoundFiler.free(soundfiler);
   }
  
}
