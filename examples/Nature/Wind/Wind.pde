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
  
  double f = map(mouseX, 0, width, .01, .3);
  music.setWind(f);
  output = music.getOutput();
 
 //Draw the shape based on the output block, once per frame
  beginShape();
  for(int i = 0; i < output.length; i++){
    vertex(
      map(i, 0, output.length, width, 0),
      map((float)output[i], -.1, .1, 0, height)
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
   
   private int block = 512;
   private int counter = 0;
   double [] myOutput = new double[block];
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     out = wind.perform();
     outputL = out[0];
     outputR = out[1];
     
      //This is for graphing the windspeed to our main graphics window
     myOutput[counter++] = (outputL + outputR) * .5;  
     if(counter == block) counter = 0;
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setWind(double f1) {
     wind.setWindFreq(f1);
   }
   
   synchronized double [] getOutput() {
     return myOutput;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     wind.free();
     
   }
   
 }
