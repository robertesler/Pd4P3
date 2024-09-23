import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float dummyFloat = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  // float f = map(mouseX, 0, width, 50, 800);
  // music.setBW(f);
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
   
   double freq = 100; //50-2000
   double decay = .1; //2-60
   double cf = 500; //100-5000
   double bw = 400; //10-1000
   double noiseMix = 25; //0-100
   double gain = .8; //0-1
   boolean bang = false;
   
   Noise noise = new Noise();
   Oscillator [] osc = new Oscillator[4];
   Oscillator oscNoiseBand = new Oscillator();
   Oscillator oscTone = new Oscillator();
   Line lineDecay = new Line();
   Line lineDecay2 = new Line();
   Line lineExp = new Line();
   Butterworth butterworth = new Butterworth();
   
   public MyMusic() {
     
     for(int i = 0; i < 4; i++)
       osc[i] = new Oscillator();
     
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     if(getBang())
     {
      //reset our envelopes
      lineDecay.perform(0,0);
      lineDecay2.perform(0,0);
      lineExp.perform(0,0);
     }
     
     double toneGain = 1-(noiseMix/100);
     double noiseBand = (butterworth.perform(noise.perform(), getBW(), 5000, 0, false) * noiseMix/100) * oscNoiseBand.perform(getCF()); 
     double rdrum = ( (osc[0].perform(getFreq())*.167) + (osc[1].perform(getFreq()*1.6)*.25) + (osc[2].perform(getFreq()*2.2)*.333) +
                    (osc[3].perform(getFreq()*2.6)*.25) ) * toneGain;
     double stage1 = (noiseBand + rdrum) * percussionEnv(getDecay() * .5);
     double output = stage1 + (oscTone.perform(getFreq()) * toneGain);//need to implement percussionEnv as class
     outputL = outputR = output * getGain();
     
   }
   
   private double percussionEnv(double dur) {
        double halflife = (log(2)/10) * -1;
        double l = lineExp.perform(100, dur*1000) * halflife;
        double output = exp((float)l);
        return output;
    }
  
  public void setDecay(double d) {
   decay = d; 
  }
  
  public double getDecay() {
   return decay; 
  }
  
  public void setBW(double f) {
     bw = f;
  }
  
  public double getBW() {
   return bw; 
  }
  
  public void setCF(double c) {
    cf = c; 
  }
  
  public double getCF() {
   return cf; 
  }
  
  public void setFreq(double f) {
    freq = f; 
  }
  
  public double getFreq() {
    return freq;  
  }
  
  public void setGain(double g) {
   gain = g; 
  }
  
  public double getGain() {
   return gain; 
  }
  
  public void setBang(boolean b) {
   bang = b; 
  }

  public boolean getBang() {
   return bang; 
  }
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     for(int i = 0; i < 4; i++)
       Oscillator.free(osc[i]);
      
      Oscillator.free(oscNoiseBand);
      Oscillator.free(oscTone);
      Line.free(lineDecay);
      Line.free(lineDecay2);
      Line.free(lineExp);
      butterworth.free();
   }
   
 }
