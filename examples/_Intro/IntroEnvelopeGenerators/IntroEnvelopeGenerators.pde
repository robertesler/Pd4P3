import com.pdplusplus.*;

/*
The next step is to shape our generators using envelopes
An envelope is just a change of amplitude over time.
In Pd++ we use the Line class
FYI the Envelope class in Pd++ measures the ampltidue over time, not generate it.
*/

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
  float f = map(mouseX, 0, width, 200, 500);
  music.setFreq(f);
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
   
   float freq = 0;
   Oscillator osc = new Oscillator();
   Line line = new Line();
   boolean bang = false;
   double amplitude = 0;
   double attack = 20;
   double release = 100;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     //trigger our envelope
     if(getBang())
       amplitude = line.perform(1, attack);
     else
       amplitude = line.perform(0, release);
     
     //once we reach peak, go back to 0, turn off trigger
     if(amplitude == 1)
     {
        setBang(false);
     }
     
     //then we will envelope our signal generator by our amplitude, scaled down by .3
     outputL = outputR = osc.perform(getFreq()) * amplitude * .3; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   synchronized void setBang(boolean b) {
     bang = b; 
   }
   
   synchronized boolean getBang() {
     return bang;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc);
     Line.free(line);
     
   }
   
 }
