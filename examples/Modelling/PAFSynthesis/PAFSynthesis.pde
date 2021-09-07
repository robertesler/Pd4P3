import com.pdplusplus.*;

/*
This sketch demonstrates phase aligned formant synthesis.  This
algorithm is patented by IRCAM but allowable for open source or
educational purposes, but don't go selling software with this unless
you contact them first. 

One use of PAF is speech synthesis, but it is useful for making
synths or vocoders.  

Use mouse X/Y to control the frequency and index of the
synthesizer.  

The animation is the frequency bands and their amplitude.
*/

 Pd pd;
 MyMusic music;
 
double bins[];
double smooth[];

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   pd.setFFTWindow(1024);
   music.setSynth();
   bins = new double[pd.getFFTWindow()];
   smooth = new double[pd.getFFTWindow()];
   music.createHann(pd.getFFTWindow());
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
   float f = map(mouseX, 0, width, 50, 250);
   float index = map(mouseY, 0, height, 200, 10);
   //We set the center frequency to 1/10 of the fundamental.  
   music.setFreq(f, f/10, index);
   background(255);
   fill(0);
   String s = "Hz: " + str(f) + " Index: " + str(index);
   text(s, 50, 50);
   
   bins = music.getBins();
  fill(0, 100, 200);
  noStroke();
  
  for(int i = 0; i < pd.getFFTWindow(); i++)
  {
    float x, y, w, h;
    smooth[i] += (bins[i] - smooth[i]) * .6;
    w = width/(pd.getFFTWindow() * .5);
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
    music.stopWrite();
    super.dispose();
}
 
 /*
   This class implements a PAF object and then analyzes it.
   The FFT bin magnitude is then sent back to P3 for drawing.
 */
 class MyMusic extends PdAlgorithm {
   
   PAF paf = new PAF();
   rFFT rfft = new rFFT();
   rIFFT rifft = new rIFFT();
   Oscillator osc = new Oscillator();
   WriteSoundFile writesf = new WriteSoundFile();
   double freq = 100;
   double centerFreq = 10;
   double index = 50;
   double[] sf = new double[1];
   boolean recording = false;//Set this to true if you want to record what you do.
   
   double[] bins;
   double[] hannWindow;
   double[] fftBin;
   int windowSize = 0;
   int counter = 0;

   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
      
     //get our Hanning window
     double hann = hannWindow[counter++];
     //perform our PAF with freq, center freq and modulation index
     double out = paf.perform(getFreq(), getCenterFreq(), getIndex());
     
     sf[0] = out;
     if(recording)
       writesf.start(sf);
     
     fftBin = rfft.perform(out * hann);
    
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
     
     outputL = outputR = out; 
     
   }
   
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
   
  void stopWrite() {
    if(recording)
       writesf.stop(); 
  }
  
  void setSynth() {
    if(recording)
      writesf.open("C:\\Users\\&&&\\Desktop\\paf.wav", 1);
    
     paf.setSynth(); 
  }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(double f, double cf, double i) {
     freq = f;
     centerFreq = cf;
     index = i;
   }
   
   synchronized double getFreq() {
     return freq;
   }
   
   synchronized double getCenterFreq() {
     return centerFreq;
   }
   
   synchronized double getIndex() {
     return index;
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
     paf.free();
     rFFT.free(rfft);
     rIFFT.free(rifft);
     Oscillator.free(osc);
     
   }
   
 }
