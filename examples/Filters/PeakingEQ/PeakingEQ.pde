import com.pdplusplus.*;

/*
This is an example of a Peaking EQ filter, and how you could
 create a custom filter using your own recipe.
 This is our biquad transfer function
 H(z) = b0 + b1*z^-1 + b2*z^-2/ a0 + a1*z^-1 + a2*z^-2
 
 Taken from the "Cookbook Formulae for Audio EQ Biquad Filter Coefficients"
 by Robert Bristow-Johnson <robert@wavemechanics.com>
 
 our formula: (b0 * input) + (b1 * x1) + (b2 * x2) - (a1 * y1) - (a2 * y2);
 b0 = 1 + alpha*A
 b1 = -2*cos
 b2 = 1 - alpha*A
 a0 = 1 + alpha/A
 a1 = -2*cos
 a2 = 1 - alpha/A
 
 A = 10^(dBgain/40)
 omega = 2*pi*freq/sr
 alpha = sin(omega)/(2*Q)
 note: sin = sin(omega), cos = cos(omega)
 */

Pd pd;
MyMusic music;
double bins[];
double smooth[];
int counter = 0;
final int fftWindowSize = 512;
final float maxFreq = 1000;

void setup() {
  size(640, 360);

  music = new MyMusic();
  pd = Pd.getInstance(music);
  pd.setFFTWindow(fftWindowSize);
  bins = new double[fftWindowSize];
  smooth = new double[fftWindowSize];
  music.createHann(fftWindowSize);
  //start the Pd engine thread
  pd.start();
}

void draw() {
  background(0);
  float f = map(mouseX, 0, width, 0, maxFreq);
  float g = map(mouseY, height, 0, -12, 12);
  music.setFreq((double)f);
  music.setGain((double)g);
  text(str((int)f) + "Hz | " + str((int)g) + " dB", mouseX+10, mouseY);
 
  //our analysis graph
  bins = music.getBins();
  fill(0, 100, 200);
  noStroke();
  float range = (maxFreq/music.getSampleRate()) * (float)fftWindowSize;
  range += 1;
  
  for(int i = 0; i < range; i++)
  {
    float x, y, w, h;
    smooth[i] += (bins[i] - smooth[i]) * .6;
    w = width/range;
    x = w * i;
    h = (float)-smooth[i] * height * 10;
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

  double alpha = 0;//sin(omega)/(2*Q)
  double A = 0;//10^(dBgain/40)
  double omega = 0; //freq/sr
  double x1, x2, y1, y2;
  double a0, a1, a2, b0, b1, b2;
  double freq = 0;
  double dbGain = 0;
  double Q = 1;

  Cosine cos= new Cosine();
  Cosine cos_sin = new Cosine();
  Noise noise = new Noise();
  
  //for our analysis and graphics
  rFFT rfft;
  rIFFT rifft;
  Oscillator osc = new Oscillator();
  double[] bins;
  double[] hannWindow;
  double[] fftBin;
  int windowSize = 0;
  int counter = 0;
  int index = 0;

  void runAlgorithm(double in1, double in2) {

    A = pow(10, (float)(this.getGain()/40.0));
    omega = this.getFreq()/this.getSampleRate();//Pd4P3 uses scalar freq (0-1) not radians
    double cosOmega = cos.perform(omega);
    alpha = this.sin(omega)/ (2.0 * Q);

    if (dbGain >= 0)
    {
      b0 = 1 + alpha*A;
      b1 = -2*cosOmega;
      b2 = 1 - alpha*A;
      a1 = -2*cosOmega;
      a2 = 1 - alpha/A;
    } 
    else
    {
      b0 = 1 + alpha/A;
      b1 = -2*cosOmega;
      b2 = 1 - alpha/A;
      a1 = -2*cosOmega;
      a2 = 1 - alpha*A;
    }

    a0 = 1 + alpha / A;
    b0 /= a0;
    b1 /= a0;
    b2 /= a0;
    a1 /= a0;
    a2 /= a0;

    double input = noise.perform();
    double output = (b0 * input) + (b1 * x1) + (b2 * x2) - (a1 * y1) - (a2 * y2);

    // Shift stored values
    x2 = x1;
    x1 = input;
    y2 = y1;
    y1 = output;
    outputL = outputR = output;
    
    //our analysis phase, we'll use this for graphing
    double hann = hannWindow[counter++];
    fftBin = rfft.perform(output * hann);
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
    
  }

  //We use the phase shift of 90 degrees for our sin table lookup
  double sin(double x) {
   return cos_sin.perform(x - .25); //.25 = 1/4 phase or 90 degrees
  }
  
  /*
     We need to create a Hanning Window to smooth the FFT input
   */
   void createHann(int ws) {
     //create our fft and ifft objects with proper window size
     rfft = new rFFT(ws);
     rifft = new rIFFT(ws);
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
   
   //getter / setters
  void setBins(double[] b) {
     
     for(int i = 0 ; i < b.length; i++)
     {
       bins[i] = b[i];
     }
    
   }
   
  synchronized double[] getBins() {
     return bins;
   }
  
  double getFreq() {
    return freq;
  }

  synchronized void setFreq(double f) {
    freq = f;
  }

  double getBandwidth() {
    return Q;
  }

  synchronized void setBandwidth(double bw) {
    Q = bw;
  }

  double getGain() {
    return dbGain;
  }

  synchronized void setGain(double g) {
    dbGain = g;
  }

  //Free all objects created from Pd4P3 lib
  void free() {
    Cosine.free(cos);
    Cosine.free(cos_sin);
    Noise.free(noise);
    Oscillator.free(osc);
    rFFT.free(rfft);
    rIFFT.free(rifft);
  }
}
