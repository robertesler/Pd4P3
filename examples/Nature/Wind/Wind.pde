import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 double [] output;


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
  
   output = music.getOutput();
 
 //Draw the shape based on the output block, once per frame
  beginShape();
  for(int i = 0; i < output.length; i++){
    vertex(
      map(i, 0, output.length/2, width, 0),
      map((float)output[i], -1, 1, 0, height)
    );
  }
  endShape(); 
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
   
   float dummy = 0;
   double [] out = new double[2];
   WindGen wind = new WindGen();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     out = wind.perform();
     outputL = out[0];
     outputR = out[1];
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFloat(float f1) {
     dummy = f1;
   }
   
   synchronized double [] getOutput() {
     return wind.getWindOutput();
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     wind.free();
     
   }
   
 }
