/*
This is how you could do the same thing yourself without the
Convolution class from Pd4P3.  It is however less efficient
and will likely cause audio interrupts.  However, I have been
successful using small window sizes, 512 for ex., but it does
not sound as good.  

This code is just for reference, if you want to perform convolution
timbre stamping then use the Convolution class as in the Timbre Stamp
example.
*/

class Convolution2 extends PdMaster {
 
   rFFT rfft;//for our input, aka filter
   rIFFT rifft;
   rFFT rfft2;//for our Synth, aka control
 
  
   Oscillator osc = new Oscillator();
   int squelch = 30;
   int overlap = 4;
   double[] fft  = new double[this.getFFTWindow()];
   double[] fft2  = new double[this.getFFTWindow()];
   double[] vocoder  = new double[this.getFFTWindow()];
   float[] hann = new float[this.getFFTWindow()];
   ArrayList<Float> buffer = new ArrayList<Float>(this.getFFTWindow());
   ArrayList<Float> buffer2 = new ArrayList<Float>(this.getFFTWindow());
   float[] in = new float[this.getFFTWindow()/overlap];
   float[] cIn = new float[this.getFFTWindow()/overlap];
   float[] sum = new float[this.getFFTWindow()];
   double[] ifft = new double[this.getFFTWindow()];
   float[] ifftWas = new float[this.getFFTWindow()];
   double[] b = new double[this.getFFTWindow()];
   long sampleCounter = 0;
   float[] out = new float[overlap];
   boolean ifThreading = false;
 
   
   Convolution2() {
   
     rfft = new rFFT(512);//for our input, aka filter
     rifft = new rIFFT(512);
     rfft2 = new rFFT(512);//for our Synth, aka control
     createHann(512);
   }
   
   Convolution2(int ws, int ov) {
     overlap = ov;
     rfft = new rFFT(ws);//for our input, aka filter
     rifft = new rIFFT(ws);
     rfft2 = new rFFT(ws);//for our Synth, aka control
     createHann(ws);
   }
   
   float perform(float filter, float control) {
    
     return doFFT(filter, control);
     
   }
   
  float doFFT(float filter, float control) {
    
     int hop = this.getFFTWindow()/overlap;
    in[(int)sampleCounter] = filter;
    cIn[(int)sampleCounter] = control; 
    
    if(sampleCounter == hop)
    {
      for(int i = 0; i < hop; i++)
      {
       
       buffer.add(in[i]);
       buffer2.add(cIn[i]);
       buffer.remove(0); 
       buffer2.remove(0);
      }
      
      //Now we perform our FFTs and multiply by our Hann window
      for(int i = 0; i < this.getFFTWindow(); i++)
      {
        fft = rfft.perform(buffer.get(i)*hann[i]);
        fft2 = rfft2.perform(buffer2.get(i)*hann[i]);
      }
      
     //multiply the magnitude of our control freq bins by our filter freq bins, aka vocoding via convolution
       vocoder = convolveFFT(fft, fft2);
           
           
      //resynthesize our FFT block, multiply by our Hann window again
       for(int i = 0; i < this.getFFTWindow(); i++)
        ifft[i] = rifft.perform(vocoder)* hann[i];
 
      /* Now we overlap our windows, and add them together*/
      
      for(int i = 0 ; i < this.getFFTWindow(); i++)
          sum[i] = (float)ifft[i] + (i+hop < this.getFFTWindow() ? ifftWas[i+hop] : 0);
      
      ifftWas = sum;
      
      sampleCounter = -1;
    }
    
    sampleCounter++;
   return  sum[(int)sampleCounter]/(this.getFFTWindow()*1.5);//divide by 3N/2
  }
  
  /*
    This is a convolution of two FFT blocks
  */
  public double[] convolveFFT(double[] filter, double[] control) {
    
    //Real FFT puts the real on the front half or the window array, and imaginary on the back half
      for(int i = 0,  j = this.getFFTWindow()-1; i < this.getFFTWindow()/2; i++, j--) {
        
        //Get the magnitude of each bin of our filter input (live mic or recording)
          float realFilter = (float)filter[i];
          float imagFilter = (float)filter[j];
          //rsqrt( real^2 + imag^2) = freq bin magnitude
          float magnitudeFilter = rsqrt( (realFilter * realFilter) + (imagFilter * imagFilter) 
          + 1e-020);
          
          float sq = getSquelch();
          magnitudeFilter = clip(magnitudeFilter, 0, 0.01*sq*sq);
          
          //Get the magnitude of our control input, our synth or whatever else you like.
          float realControl = (float)control[i];
          float imagControl = (float)control[j];
          //sqrt( real^2 + imag^2) = freq bin magnitude
          float magnitudeControl = sqrt( (realControl * realControl) + (imagControl * imagControl) );
          
          
          float f = (magnitudeFilter * magnitudeControl) ;
          b[i] = realFilter * f;
          b[j] = imagFilter * f;
      
        }
        
    return b;
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
 
     /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann(int ws) {
     
     int windowSize = ws;
     float winHz = 0;
     
   //clear our buffer first thing, it only does this once
   if(buffer.size() == 0)
    {
      float d= 0;
       for(int i = 0; i < this.getFFTWindow(); i++)
       {
         buffer.add(d);
         buffer2.add(d);
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
        hann[i] = (float)((osc.perform(winHz)* -.5) + .5);
      }
       
 }
  
    //emulate [clip~], a = input, b = low range, c = high range
   private float clip(float a, float b, float c) {
     if(a < b)
       return b;
      else if(a > c)
       return c;
      else
        return a;
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setSquelch(int sq) {
     squelch = sq;
   }
   
   synchronized float getSquelch() {
     return squelch;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     rFFT.free(rfft);
     rIFFT.free(rifft);
     rFFT.free(rfft2);
     Oscillator.free(osc);
   }
   
}
  
