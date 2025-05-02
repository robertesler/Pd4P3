import com.pdplusplus.*;

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
   double t = map(mouseX, 0, width, 0, 1);
   music.setTime(t);
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
   
   double time = .5;
   MotorGenerator motor = new MotorGenerator();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = motor.perform(); 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setTime(double t) {
      motor.setRuntime(t);
   }
   
   synchronized double getTime() {
     return motor.getRuntime();
   }
   
    synchronized void setBang(boolean b) {

        motor.setGo(b);
    }
     
   //Free all objects created from Pd4P3 lib
   void free() {
     
     motor.free();
   }
   
 }
