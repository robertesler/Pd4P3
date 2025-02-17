import com.pdplusplus.*;

/*
A simple implementation of Perlin Noise
The x-axis will set the noise scale which will
change the spectrum of the noise.  
*/

 Pd pd;
 MyMusic music;
 int counter = 0;
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
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  //set our scale from .005 = .09, change if you like
  float s = map(mouseX, 0, width, .005, .09);
  music.setScale(s);
  output = music.getOutput();
 
 //Draw the shape based on the output block, once per frame
  beginShape();
  for(int i = 0; i < output.length; i++){
    vertex(
      map(i, 0, output.length, width, 0),
      map(output[i], -1, 1, 0, height)
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
   This is our audio class that writes noise() directly to the audio loop
 */
 class MyMusic extends PdAlgorithm {
   
   float x = 0;
   int counter = 0;
   int block = 1024; //change this to bigger or small to get better graphing
   float[] writeOutput = new float[block];
   float scale = .01;
   
   //Our audio loop.  All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     x = x + getScale();
     float n = noise(x);
     outputL = outputR = n - .5; //drop down 50% to avoid DC
     
     //our ring buffer
     writeOutput[counter++] = (float)outputL;
     //writes a block to our graphics loops
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
     
   }
   
   synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   
   synchronized void setScale(float s) {
      scale = s; 
   }
   
   synchronized float getScale() {
      return scale; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     
     //nothing to free
   }
   
 }
