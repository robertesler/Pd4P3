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
 
 void mousePressed() {
   music.setBang(true); 
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
   
   double freq = 100; //50-2000 Hz
   double decay = 2; //2-60 secs
   double cf = 500; //100-5000 Hz
   double bw = 400; //10-1000 Hz
   double noiseMix = 25; //0-100 %
   double gain = .8; //0-1 linear
   boolean bang = false;
   
   Noise noise = new Noise();
   Oscillator [] osc = new Oscillator[4];
   Oscillator oscNoiseBand = new Oscillator();
   Oscillator oscTone = new Oscillator();
   PercussionEnvelope percEnv1 = new PercussionEnvelope();
   PercussionEnvelope percEnv2 = new PercussionEnvelope();
   PercussionEnvelope percEnv3 = new PercussionEnvelope();
   Butterworth butterworth = new Butterworth();
   
   public MyMusic() {
     
     for(int i = 0; i < 4; i++)
       osc[i] = new Oscillator();
            
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     
      if(getBang())
     {
       osc[0].setPhase(-.25);
       osc[1].setPhase(-.25);
       osc[2].setPhase(-.25);
       osc[3].setPhase(-.25);
       oscTone.setPhase(-.25);
       oscNoiseBand.setPhase(0);
     }
     
     double toneGain = 1-(noiseMix/100);
     double noiseBand = (butterworth.perform(noise.perform(), getBW(), 5000, 0, false) * noiseMix/100) * 
                         oscNoiseBand.perform(getCF()); 
     double rdrum = ( (osc[0].perform(getFreq())*.167) + (osc[1].perform(getFreq()*1.6)*.25) + 
                      (osc[2].perform(getFreq()*2.2)*.333) +  (osc[3].perform(getFreq()*2.6)*.25) ) * toneGain;
     double stage1 = (noiseBand + rdrum) * percEnv1.perform(getDecay() * .5, getBang());
     double tone = oscTone.perform(getFreq());
     double output = (stage1 + (tone * toneGain)) * percEnv2.perform(getDecay(), getBang());
     
    
     setBang(false);
     outputL = outputR = output * getGain();
     // outputL = outputR = 0;
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
      percEnv1.free();
      percEnv2.free();
      percEnv3.free();
      butterworth.free();
   }
   
 }
