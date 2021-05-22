import com.pdplusplus.*;
import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float modulationIndex = 400;
 float carrier = 100;
 float delayTime = 500;
 float delayFeedback = .3;
 boolean circleDraw = false;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   
   carrier = map(mouseX, 0, width, 400.0, 1200.0);
   music.setCarrierFreq(carrier);
   
   delayTime = map(mouseX, 0, width, 50.0, 300.0);
   music.setTime(delayTime);

   modulationIndex = map(mouseY, 0, height, 10.0, 350.0);
   music.setModIndex(modulationIndex);
   
   delayFeedback = map(mouseY, 0, height, .1, .9);
   music.setFeedback(delayFeedback);

   if(circleDraw)
   {
     background(255);
       color c = color(map(modulationIndex, 10, 350, 10, 255), map(carrier, 400, 1200, 10, 255), map(mouseX, 0, width, 10, 255));  // Define color 'c'
      fill(c);  // Use color variable 'c' as fill color
      noStroke();  // Don't draw a stroke around shapes
      circle(mouseX, mouseY, 55); 
      circleDraw = false;
      music.setBang(circleDraw);
   }
 }
 
 void mouseClicked() {
   music.setBang(true);
   circleDraw = true;
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped");
    super.dispose();
}
 
 
 class MyMusic extends PdAlgorithm {
   
   //create new objects like this
    Oscillator osc1 = new Oscillator();
    Oscillator osc2 = new Oscillator();
    Oscillator osc3 = new Oscillator();
    Line line = new Line();
    VariableDelay vd = new VariableDelay();
    float modFreq = 300;
    float modIndex = 100;
    float carrierFreq = 200;
    float amplitude = 1;
    float delayTime = 500;
    float pDelayTime = 500;//for lerp(), previous value
    float delayFeedback = .3;
    float pDelayFeedback = .3;//for lerp(), previous value
    boolean bang = false;
    float attack = 50;
    float release = 750;
    double env = 0;
    double t = 0; //smoothing
     
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     //Classic FM 
     double fm = osc1.perform( carrierFreq + ( osc2.perform(carrierFreq * 2.5)* getModIndex()) ) * (amplitude * env );
     t = t - .0001 * (t - getTime()); //smooth our delayTime to get rid of crackles
     //Our delayed output with doppler
     double out = vd.perform( getTime() *  t ) + (double)fm; //add fm to our delay line  
     vd.delayWrite(out * getFeedback());//feedback our output with an amplitude multiplier less than 1. 
    
     outputL = outputR = out;

     /*
     This is how to do an envelope using Line()
     */
     if(getBang())
     {
     env = line.perform(1, attack);  
     }
     else
     {
      env = line.perform(0, release); 
     }
     
     if(env == 1)
     {
       bang = false;
     }
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setModIndex(float f1) {
     modIndex = f1;
   }
   
   synchronized float getModIndex() {
      
     return modIndex;
   }
   
    synchronized void setCarrierFreq(float f1) {
     carrierFreq = f1;
   }
   
   synchronized float getCarrierFreq() {
    
     return carrierFreq;
   }
   
   synchronized void setTime(float f1) {
     delayTime = f1;
   }
   
   synchronized float getTime() {
     return delayTime;
   }
   
   synchronized void setFeedback(float f1) {
     delayFeedback = f1;
   }
   
   synchronized float getFeedback() {
     return delayFeedback;
   }
   
   synchronized void setBang(boolean b) {
     bang = b;
   }
   
  synchronized boolean getBang() { 
     return bang;
   }
   
   void free() {
     Oscillator.free(osc1);
     Oscillator.free(osc2);
     Oscillator.free(osc3);
     Line.free(line);
     VariableDelay.free(vd);
   }
   
 }
