import com.pdplusplus.*;


//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq1 = 400;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
 }
 
 void draw() {
   freq1 = map(mouseX, 0, width, 200.0, 800.0);
   music.setFreq(freq1);
   //System.out.println("freq1: " + freq1);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Print this when sketch is stopped.");
    super.dispose();
}
 
 
 class MyMusic extends PdAlgorithm {
   
   //create new objects like this
    Oscillator osc1 = new Oscillator();
    Oscillator osc2 = new Oscillator();
    float oscFreq = 300;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = osc1.perform(getFreq()) * .5 + osc2.perform(getFreq() * 1.5) *.5; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     oscFreq = f1;
     notify();
   }
   
   synchronized float getFreq() {
     return oscFreq;
   }
   
   void free() {
     Oscillator.free(osc1);
     Oscillator.free(osc2);
     
   }
   
 }
