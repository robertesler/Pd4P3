import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 double bins[];
 double smooth[];
 int counter = 0;
 final int fftWindowSize = 64;

 void setup() {
   size(640, 360);
   background(210, 210, 210);
    
   music = new MyMusic();
   
   pd = Pd.getInstance(music);
   //Make sure to set the FFT window size in Pd4P3
   pd.setFFTWindow(fftWindowSize);
   bins = new double[fftWindowSize];
   smooth = new double[fftWindowSize];
   music.createHann(fftWindowSize);
  
   //start the Pd engine thread
   pd.start();
  
   
 }
 
 void draw() {
  background(210, 210, 210);
  bins = music.getBins();
  fill(0, 100, 200);
  noStroke();
  
  for(int i = 0; i < fftWindowSize; i++)
  {
    float x, y, w, h;
    smooth[i] += (bins[i] - smooth[i]) * .6;
    w = width/(fftWindowSize * .5);
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
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   rFFT rfft = new rFFT();
   rIFFT rifft = new rIFFT();
   Oscillator osc = new Oscillator();
   LowPass lop = new LowPass();
   Noise noise = new Noise();
   double[] bins;
   double[] hannWindow;
   double[] fftBin;
   int windowSize = 0;
   int counter = 0;
   int index = 0;
   
   /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann(int ws) {
     double winHz = 0;
     windowSize = ws;
     fftBin = new double[ws];
     
     if(windowSize != 0) {
        winHz = this.getSampleRate()/windowSize;
     }
     else {
       windowSize = 32;
       println("Window size cannot be zero!");
     }
     
     hannWindow = new double[windowSize];
     bins = new double[windowSize];
        
       osc.setPhase(0);
     for(int i = 0; i < windowSize; i++)
     {
       hannWindow[i] = ((osc.perform(winHz)* -.5) + .5);
       bins[i] = 0;
     }
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
    
     //get our Hanning window
    double hann = hannWindow[counter++];
    lop.setCutoff(800);
    double input = lop.perform( noise.perform() ) + osc.perform(400) * .5 ;
        
    fftBin = rfft.perform(input * hann);
    
    //Calculate magnitude of each bin
    if(counter == windowSize) 
    {
      //Real FFT puts the real on the front half or the window array, and imaginary on the back half
      for(int i = 0,  j = windowSize-1; i < windowSize/2; i++, j--) {
          double real = fftBin[i];
          double imag = fftBin[j];
          //sqrt( real^2 + imag^2) = freq bin magnitude
          double magnitude = sqrt( (float)(real * real) + (float)(imag * imag) );
         
          bins[i] = magnitude/windowSize;//scale it by ws
      
        }
      
       setBins(bins);
       counter = 0;
    }
     
     outputL = outputR = input; 
     
  }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setBins(double[] b) {
     
     for(int i = 0 ; i < b.length; i++)
     {
       bins[i] = b[i];
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
     LowPass.free(lop);
     Noise.free(noise);
     
   }
   
 }
