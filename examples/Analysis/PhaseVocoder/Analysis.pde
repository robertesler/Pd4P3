class Analysis extends PdMaster {
  
   rFFT rfft;
   rFFT rfft2;
   rIFFT rifft;
   Oscillator osc = new Oscillator();
   Line line = new Line();
   LRShift [] lrshift = new LRShift[4];
   TabRead4 tab1 =  new TabRead4();
   TabRead4 tab2 =  new TabRead4();
   double[] hann;
   double[] prevReal;
   double[] prevImag;
   double[] sample; //our sample table
   double index1 = 0;
   double index2 = 0;
   int hannIndex = 0;
   ArrayList<Double> buffer;
   double location = 0;
   double speed = 0;
   boolean rewind = false;
   int auto = 100;
   double transpo = 0;
   boolean lock = false;
   int currentWindowSize = fftWindowSize;
  
  
   Analysis()  {
      rfft = new rFFT(fftWindowSize);
      rifft = new rIFFT(fftWindowSize);
      rfft2  = new rFFT(fftWindowSize);
      hann = new double[fftWindowSize];
      prevReal = new double[fftWindowSize];
      prevImag = new double[fftWindowSize];
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
    rFFT.free(rfft2);
    rIFFT.free(rifft);
    TabRead4.free(tab1);
    TabRead4.free(tab2);
    Oscillator.free(osc);
    Line.free(line);
  }
}
