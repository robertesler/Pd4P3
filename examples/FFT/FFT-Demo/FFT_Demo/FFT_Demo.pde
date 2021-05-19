import com.pdplusplus.*;
import com.portaudio.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 double bins[];
 int counter = 0;

 void setup() {
   size(640, 360);
   background(255);
    
   music = new MyMusic();
   
   pd = Pd.getInstance(music);
   pd.setFFTWindow(32);
   bins = new double[pd.getFFTWindow()];
   music.createHann(pd.getFFTWindow());
  // bins = new double[music.getFFTWindow()];
   //start the Pd engine thread
   pd.start();
  
   
 }
 
 void draw() {
  
  bins = music.getBins();
  
  fill(50);
  text((float)bins[counter++], 10, 10);  // Text wraps within text box
  if(counter == pd.getFFTWindow()) counter = 0;
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
   double[] bins;
   double[] hannWindow;
   double[] fftBin;
   int windowSize = 0;
   int counter = 0;
   int index = 0;
   
   /*
     We need to create a Hanning Window to smooth the FFT input and output
   */
   void createHann(int ws) {
     double winHz = 0;
     windowSize = ws;
     fftBin = new double[ws];
     
     if(windowSize != 0) {
        winHz = this.getSampleRate()/windowSize;
     }
     else {
       windowSize = 64;
       println("Window size cannot be zero!");
     }
     
     hannWindow = new double[windowSize];
     bins = new double[windowSize];
        
       osc.setPhase(.5);
     for(int i = 0; i < windowSize; i++)
     {
       hannWindow[i] = ((osc.perform(winHz)* .5) + .5);
       bins[i] = 0;
     }
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
    double hann = hannWindow[counter++];
    
    //get our Hanning smoothed input
    double input = ((in1 + in2) * .5) * hann;
   
    
    fftBin = rfft.perform(input);
   
    double out = rifft.perform(fftBin) * hann ;
    
    
    if(counter == windowSize) 
    {
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
     
     outputL = outputR = out/windowSize; 
     
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
     
   }
   
 }
