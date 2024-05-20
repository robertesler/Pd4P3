import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 final int fftWindowSize = 2048;


 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   //make sure to set the FFT window size in Pd4P3
   pd.setFFTWindow(fftWindowSize);
    //You can use Processing's data path which is ./data/filename.wav or whatever.  Or see FileNameHelper example
   String path = this.dataPath("voice.wav");
   music.loadSample(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
   fill(0);
   float s = map(mouseX, 0, width, 0, 20);
   music.setSpeed(s);
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
   
   float speed = 0;
   Analysis pvoc = new Analysis();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = pvoc.perform(); 
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setSpeed(float s) {
     pvoc.setSpeed(s);
   }

   //do this first please
   void loadSample(String f) {
      pvoc.inSample(f); 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     pvoc.free(); 
   }
   
 }
