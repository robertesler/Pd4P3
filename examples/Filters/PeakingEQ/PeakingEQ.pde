import com.pdplusplus.*;

/*
This is an example of a Peaking EQ filter, and how you could
 create a custom filter using your own recipe.
 This is our biquad transfer function
 H(z) = b0 + b1*z^-1 + b2*z^-2/ a0 + a1*z^-1 + a2*z^-2
 
 Taken from the "Cookbook Formulae for Audio EQ Biquad Filter Coefficients"
 by Robert Bristow-Johnson <robert@wavemechanics.com>
 
 our formula: H(s) = (s^2 + s*(A/Q) + 1)/ (s^2 + s(A*Q) + 1)
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

//declare Pd and create new class that inherits PdAlgorithm
Pd pd;
MyMusic music;

void setup() {
  size(640, 360);
  background(255);


  music = new MyMusic();
  pd = Pd.getInstance(music);

  //start the Pd engine thread
  pd.start();
}

void draw() {
  background(0);
  float f = map(mouseX, 0, width, 50, 500);
  float g = map(mouseY, height, 0, -12, 12);
  music.setFreq((double)f);
  music.setGain((double)g);
  text(str(f) + " | " + str(g), mouseX, mouseY);
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
  double omega = 0; //2*pi*freq/sr
  double x1 = 0;
  double x2 = 0;
  double y1 = 0;
  double y2 = 0;
  double a0, a1, a2, b0, b1, b2;
  double freq = 0;
  double dbGain = 0;
  double bw = 10;// in octaves
  int counter = 1;

  Cosine cos_sig = new Cosine();
  Cosine cos_sin = new Cosine();
  Noise noise = new Noise();
  Oscillator osc = new Oscillator();

  //All DSP code goes here
  void runAlgorithm(double in1, double in2) {

    A = pow(10, (float)(this.getGain()/40.0));
    omega = 2.0 * PI * ( this.getFreq()/this.getSampleRate() );

    double cosOmega = this.cos(omega);
    alpha = this.sin(omega)/ (2.0 * bw);

    if (dbGain >= 0)
    {
      b0 = 1 + alpha*A;
      b1 = -2*cosOmega;
      b2 = 1 - alpha*A;
      a1 = -2*cosOmega;
      a2 = 1 - alpha/A;
    } else
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

    // base case
    if (Double.isNaN(output))
    {
      y1 = y2 = 0;

      //println("ROW1: " + a0 + " | " + a1 + " | " + a2 + " | " + b0 + " | " + b1 + " | " + b2);
      //print("ROW2: " + x1 + " | " + x2 + " | " + y1 + " | " + y2);
    } else
    {
      // Shift stored values
      x2 = x1;
      x1 = input;
      y2 = y1;
      y1 = output;
      outputL = outputR = output;
    }
  }

  double cos(double x) {
    return  cos_sig.perform(x);
  }

  double sin(double x) {
    //return  Math.sin(x) ;
   return  Math.sqrt(1 - cos_sin.perform(x)*cos_sin.perform(x));
   
  }

  double getFreq() {
    return freq;
  }

  synchronized void setFreq(double f) {
    freq = f;
  }

  double getBandwidth() {
    return bw;
  }

  synchronized void setBandwidth(double bw) {
    this.bw = bw;
  }

  double getGain() {
    return dbGain;
  }

  synchronized void setGain(double g) {
    dbGain = g;
  }

  //Free all objects created from Pd4P3 lib
  void free() {
    Cosine.free(cos_sig);
    Cosine.free(cos_sin);
    Noise.free(noise);
    Oscillator.free(osc);
  }
}
