import com.pdplusplus.*;


/*
This is based on example I10.phase.bash.pd
The sketch will analyze an audio file and apply 
a linear filter across the center of all FFT frequency bins
thus "bashing" all the spectral components to zero.
Then the analysed audio is played back four timess,
each slightly out-of-phase with the other thus creating
a unique type of phase modulation. 

You can control the pitch, spectral shift in this example
but also this provides access to the time and location "loco".
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 int fftWindowSize = 1024;
 double loco = 400;
 double time = 4000;
 double specshift = 12;
 double pitch = 48;
 
 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   pd.setFFTWindow(fftWindowSize);
   pd.setSampleRate(44100);
   String path = this.dataPath("voice.wav");
   music.loadSample(path);
   music.setPitch(pitch);
   music.setSpecShift(specshift);
   music.setLoco(loco);
   music.setTime(time);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
    specshift = map(mouseX, 0, width, -18, 18);
    pitch = map(mouseY, height, 0, 26, 56);
    music.setSpecShift(specshift);
    music.setPitch(pitch);
 }
 
 void mousePressed() {
  
   music.setLoco(loco);
   music.setTime(time);
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
   
   Playback playback = new Playback();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double out = playback.perform();
     outputL = outputR = out; 
   }
  
  public void loadSample(String f) {
      playback.inSample(f); 
  }
  
  
  synchronized void setLoco(double l) {
    playback.setLoco(l);
  }
  //We use synchronized to communicate with the audio thread
   synchronized void setPitch(double p) {
     playback.setPitch(p);
   }
   
   synchronized void setTime(double t) {
      playback.setTime(t); 
   }
   
   synchronized void setSpecShift(double shift) {
      playback.setSpecShift(shift);
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     playback.free();
   }
   
 }
