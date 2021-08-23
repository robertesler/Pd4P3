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
  
   //start the Pd engine thread
   pd.start();
  
   
 }
 
 void draw() {
 float x = map(mouseX, 0, width, 0, 128);
 music.setFilter((int)x);
 
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  music.wavStop();
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
   
   rFFT rfft = new rFFT();
   rIFFT rifft = new rIFFT();
   Oscillator osc = new Oscillator();
   Noise noise = new Noise();
   WriteSoundFile wav = new WriteSoundFile();
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
   long global = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
    
    double input = noise.perform() ;
    double out = 0;
    out = overlapFFT(input);     
    double[] wavOut = new double[2];
   
    outputL = outputR = out;
    wavOut[0] = outputL;
    wavOut[1] = outputR;
    if(writeAudio)
      wav.start(wavOut);
     
  }
   
  synchronized void setFilter(int x) {
    createFilter(x);
  }
   
  double overlapFFT(double input) {
    
    int hop = this.getFFTWindow()/overlap;
    in[(int)global] = input;
 
    /* now for every overlap, or hop size, add our input to the end
      of the buffer.  This will add x new samples and reuse the 
      windowsize-x previous samples.  This is our overlap buffer.
    */
    
    if(global == hop-1)
    {
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
      
      global = -1;
    }
    
    global++;
   return  sum[(int)global]/(this.getFFTWindow()*1.5);//divide by 3N/2
  
  }
  
  void wavStop() {
    if(writeAudio)
       wav.stop(); 
  }
  
  //Create a linear curve
  void createFilter(int x) {
   
    /*
    our filter curve is 1/2 our window because rFFT is half real and half imaginary
    similar to a Sasquatch...
    */
    for(int i = 0; i < filter.length; i++)
    {
      if(x > filter.length) x = filter.length;
      
        if(i < x)
          filter[i] = (double)i/filter.length;
        else
          filter[i] = (double)(x - i) / filter.length;
          
    }
    
  }
 
     /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann() {
     if(writeAudio)
       wav.open("C:\\Users\\rwe8\\Desktop\\TestFFT4.wav", 2);
    
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
     for(int j = 0; j < overlap; j++)
     {
       for(int i = 0; i < windowSize; i++)
       {
         hann[i] = ((osc.perform(winHz)* -.5) + .5);
       }
     }  
 }
   
   
   //Free all objects created from Pd4P3 lib
   void free() {
     rFFT.free(rfft);
     rIFFT.free(rifft);
     Oscillator.free(osc);
     Noise.free(noise);
     WriteSoundFile.free(wav);
     
   }
   
 }
 
 /*
 
  double overlapFFT(double input) {
    
    double sum = 0;
    //0th overlap
    if(counter[0] == this.getFFTWindow()) counter[0] = 0;
    fft[0] = rfft.perform(input*hann[0][counter[0]]); 
    out[0] = rifft.perform(fft[0])* hann[0][counter[0]];
    counter[0]++;
      
    //1st overlap
     if(global >= this.getFFTWindow()/4 )
     {   
        if(counter[1] == this.getFFTWindow()) counter[1] = 0;
        fft[1] = rfft.perform(input * hann[1][counter[1]]);
        out[1] = rifft.perform(fft[1]) * hann[1][counter[1]];
        counter[1]++;
     }
     
     
     //2nd overlap
      if(global >= this.getFFTWindow()/2)
     {   
      
      if(counter[2] == this.getFFTWindow()) counter[2] = 0;
        fft[2] = rfft.perform(input * hann[2][counter[2]]);
        out[2] = rifft.perform(fft[2]) * hann[2][counter[2]];
        counter[2]++;
      }
     
     //3rd overlap
      if(global >= this.getFFTWindow()/1.333333)
     {   
        if(counter[3] == this.getFFTWindow()) counter[3] = 0;
        fft[3] = rfft.perform(input * hann[3][counter[3]]);
        out[3] = rifft.perform(fft[3]) * hann[3][counter[3]];
        counter[3]++;
     }
     
     global++;
     
      for(int i = 0; i < overlap; i++)
     {
        sum += out[i];
     }
     
     return sum;
  }
 */
