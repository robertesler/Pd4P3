import com.pdplusplus.*;

/*
This sketch shows you how use the rFFT and iFFT classes.  The MyMusic class 
performs a overlapped windowed FFT analysis, then filters the frequency bins
using a simple curve, resynthesized them, overlaps them and adds them together
again for clean output.  
*/

 Pd pd;
 MyMusic music;
 
 double bins[];
 double smooth[];
 int counter = 0;


 void setup() {
   size(640, 360);
   background(210, 210, 210);
    
   music = new MyMusic();
   
   pd = Pd.getInstance(music);
   pd.setFFTWindow(512);
   music.createHann();
   bins = new double[pd.getFFTWindow()];
   smooth = new double[pd.getFFTWindow()];
   //start the Pd engine thread
   pd.start();
  
   
 }
 
 //We will draw our frequency bin data to the screen
 void draw() {
 background(210, 210, 210);  
 float f = map(mouseX, 0, width, 0, pd.getFFTWindow()/2);
 music.setFilter((int)f);
 bins = music.getBins();
 
 fill(0, 100, 200);
  noStroke();
  
  for(int i = 0; i < pd.getFFTWindow(); i++)
  {
    float x, y, w, h;
    smooth[i] += (bins[i] - smooth[i]) * .6;
    w = width/(pd.getFFTWindow()*.5);
    x = w * i;
    h = (float)-smooth[i] * height * 6;
    y = height;
    rect(x, y, w, h);

  }
 
 }
 

 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}

 /*
   This class will take the FFT of the input signal and then filter the frequency
   bins by a curve, see the filterCurve() method.  Then resynthesize our FFT back
   to the frequency domain.  
   The FFT analysis shows you how to use overlap-add for your FFT window.
 */
 class MyMusic extends PdAlgorithm {
   
   rFFT rfft = new rFFT(this.getFFTWindow());
   rIFFT rifft = new rIFFT(this.getFFTWindow());
   Oscillator osc = new Oscillator();
   Noise noise = new Noise();
   boolean writeAudio = false;//set this true if you want to make a recording
   int overlap = 4;
   double[] fft  = new double[this.getFFTWindow()];
   double[] hann = new double[this.getFFTWindow()];
   ArrayList<Double> buffer = new ArrayList<Double>(this.getFFTWindow());
   double[] in = new double[this.getFFTWindow()/overlap];
   double[] sum = new double[this.getFFTWindow()];
   double[] ifft = new double[this.getFFTWindow()];
   double[] ifftWas = new double[this.getFFTWindow()];
   double[] filter = new double[this.getFFTWindow()/2];
   double[] bins = new double[this.getFFTWindow()];
   long sampleCounter = 0;
   
   //Generate white noise, run it through our filter, mono output
   void runAlgorithm(double in1, double in2) {
    
    double input = noise.perform() ;
    double out = doFFT(input);        
    outputL = outputR = out;
 
  }
   
   //This is called from the P3 side
  synchronized void setFilter(int x) {
    createFilter(x);
  }
   
  double doFFT(double input) {
    
    int hop = this.getFFTWindow()/overlap;
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
      for(int i = 0; i < this.getFFTWindow(); i++)
        fft = rfft.perform(buffer.get(i)*hann[i]);
      
      
      /*
      do something with our frequency bins here
      Remember with rFFT the first half of the array is real
      the back half is imaginary.
      In this example we are just applying a very broad linear band filter.
      */
      for(int i = 0, j = this.getFFTWindow()-1; i < this.getFFTWindow()/2; i++, j--)
      {
           double gain = filter[i];
           fft[i] *= gain;//real
           fft[j] *= gain;//imag
           
          double real = fft[i];
          double imag = fft[j];
          //sqrt( real^2 + imag^2) = freq bin magnitude
          double magnitude = sqrt( (float)(real * real) + (float)(imag * imag) );
         
          bins[i] = magnitude/15;
      }
      
      //resynthesize our FFT block, multiply by our Hann window again
       for(int i = 0; i < this.getFFTWindow(); i++)
        ifft[i] = rifft.perform(fft)* hann[i];
 
      /* Now we overlap our windows, and add them together
         Basically we add the last 3/4 of the previous to the
         first 3/4 of the current resynthesized block, then 
         just zeros at the end that will carry over to the next
         block.  Genius!
      */
      for(int i = 0 ; i < this.getFFTWindow(); i++)
          sum[i] = ifft[i] + (i+hop < this.getFFTWindow() ? ifftWas[i+hop] : 0);
      
      ifftWas = sum;
      
      sampleCounter = -1;
    }
    
    sampleCounter++;
   return  sum[(int)sampleCounter]/(this.getFFTWindow()*1.5);//divide by 3N/2
  
  }
  
  /*
  Create a linear curve, you could replace this with any curve you like,
  x could be the center frequency of a band pass, or stop band or a 
  steep cutoff filter, etc.
  */
  void createFilter(int x) {
      
    /*
    our filter curve is 1/2 our window because rFFT is half real and half imaginary
    similar to a Sasquatch...
    */
    
    for(int i = 0; i < filter.length; i++)
    {
      if(x > filter.length) x = filter.length;
      
        if(i < x/2)
          filter[i] = (double)i/filter.length;
        else
          filter[i] = (double)(x - i) / filter.length;
          
    }
    
  }
 
   /*
     We need to create a Hanning Window to smooth the FFT input
     You could change this to any other type of window function 
     such as:
     Blackmann
     Rectangular
     Hamming
     Nuttall
     Gaussian
     Tukey
     etc..
   */
   void createHann() {
    
     createFilter(90);
     double winHz = 0;
     int windowSize = this.getFFTWindow();
    
    //clear our buffer first thing, it only does this once
     if(buffer.size() == 0)
     {
        double d= 0;
        for(int i = 0; i < this.getFFTWindow(); i++)
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
   
   
   synchronized double[] getBins() {
     return bins;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     rFFT.free(rfft);
     rIFFT.free(rifft);
     Oscillator.free(osc);
     Noise.free(noise);
     
   }
   
 }
