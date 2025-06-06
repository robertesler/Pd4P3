import com.pdplusplus.*;

/*
This sketch emulates the Risset Drum generator in the 
Audacity software.  

This is was translated from LISP to Java.  Original here:
https://github.com/audacity/audacity/blob/master/plug-ins/rissetdrum.ny

Click on the window to create an attack.

X = decay time
Y = frequency

*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
   double freq = 100; //50-2000 Hz
   double decay = 2; //2-60 secs
   double cf = 500; //100-5000 Hz
   double bw = 400; //10-1000 Hz
   double noiseMix = 25; //0-100 %
   double gain = .8; //0-1 linear
   float[] output;
   
 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    // Set background color, noFill and stroke style
   background(0);
   stroke(255);
   strokeWeight(2);
   noFill();
   textSize(18);
   text("Press 'q' to change cf and bw. Press 'w' to change noise and gain", 20, 20);
   text("Press 'e' for freq and decay", 20, 50);
   
   if(keyPressed)
   {
    if(key == 'q')
     {
       cf = map(mouseX, 0, width, 100, 5000);
       bw = map(mouseY, height, 0, 10, 1000);
       text("cf: " + (float)cf + " | bw: " + (float)bw, width/3, height/4);
     }
     else if (key == 'w')
     {
       noiseMix = map(mouseX, 0, width, 0, 100);
       gain = map(mouseY, height, 0, .1, .98);
       text("Noise: " + (float)noiseMix + " | Gain: " + (float)gain, width/3, height/4);
     }
     else
     {
       decay = map(mouseX, 0, width, .1, 5);
       freq = map(mouseY, height, 0, 60, 1000);
       text("Freq: " + (float)freq + " | Decay: " + (float)decay, width/3, height/4);
     } 
   }
   
   textSize(14);
   text("Freq: " + (float)freq + " Decay: " + (float)decay + " cf: " + (float)cf + " bw: " + (float)bw +
        " Noise: " + (float)noiseMix + " Gain: " + (float)gain, 20, height/1.1);
   output = music.getOutput();
   
 //Draw the shape based on the output block, once per frame
 //TODO perhaps look at syncing framerate to output.length??
   beginShape();
   for(int i = 0; i < output.length; i++) {
   vertex(
      map(i, 0, output.length, width, 0),
      map(output[i], -1, 1, 0, height)
    );
  }
  endShape(); 
 }
 
 
 void mousePressed() {
   //make sure to only update the new parameters here
   music.setBang(true); 
   music.setDecay(decay);
   music.setFreq(freq);
   music.setCF(cf);
   music.setBW(bw);
   music.setNoise(noiseMix);
   music.setGain(gain);
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
   double oneTimeGain = 0;
   
   Noise noise = new Noise();
   Oscillator [] osc = new Oscillator[4];
   Oscillator oscNoiseBand = new Oscillator();
   Oscillator oscTone = new Oscillator();
   PercussionEnvelope percEnv1 = new PercussionEnvelope();
   PercussionEnvelope percEnv2 = new PercussionEnvelope();
   PercussionEnvelope percEnv3 = new PercussionEnvelope();
   Butterworth butterworth = new Butterworth();
   
   int block = 1024; //change this to bigger or small to get better graphing
   float[] writeOutput = new float[block];
   int counter = 0;
   
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
       oneTimeGain = .95; //this is to avoid the first attack when the sketch opens
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
     outputL = outputR = output * getGain() * oneTimeGain;
       
     //our ring buffer
     writeOutput[counter++] = (float)outputL;
     
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
   }
   
 synchronized private void setOutput(float [] o) {
   writeOutput = o;
 }

 synchronized public float [] getOutput() {
    return writeOutput; 
 }

  synchronized public void setDecay(double d) {
   decay = d; 
  }
  
  synchronized public double getDecay() {
   return decay; 
  }
  
  synchronized public void setBW(double f) {
     bw = f;
  }
  
  synchronized public double getBW() {
   return bw; 
  }
  
  synchronized public void setCF(double c) {
    cf = c; 
  }
  
  synchronized public double getCF() {
   return cf; 
  }
  
  synchronized public void setFreq(double f) {
    freq = f; 
  }
  
  synchronized public double getFreq() {
    return freq;  
  }
  
  synchronized public void setGain(double g) {
   gain = g; 
  }
  
  synchronized public double getGain() {
   return gain; 
  }
  
  synchronized public void setNoise(double n) {
    noiseMix = n;  
  }
  
  synchronized public double getNoise() {
   return noiseMix; 
  }
  
  synchronized public void setBang(boolean b) {
   bang = b; 
  }

  synchronized public boolean getBang() {
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
