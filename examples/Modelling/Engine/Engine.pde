import com.pdplusplus.*;

/*
This example is based on Andy Farnell's engine examples from his book and patch
repository "Designing Sound".  

It uses waveguide synthesis to simulate the various elements of the acoustics of
a car engine.  It has three overtone excitors tuned in octaves, a four cylinder engine simulator,
and a complex fm step that creates decent synthetic engine sounds.
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
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
  float s = map(mouseX, 0, width, 0, 1);
  music.setSpeed(s);
  
  // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  
  output = music.getOutput();
 
 //Draw the shape based on the output block, once per frame
 //TODO perhaps look at syncing framerate to output.length??
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
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   float speed = 0;
   EngineGenerator engine = new EngineGenerator();
   int block = 1024; //change this to bigger or small to get better graphing
   float[] writeOutput = new float[block];
   int counter = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = engine.perform(); 
     //our ring buffer
     writeOutput[counter++] = (float)outputL;
     
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setSpeed(float s) {
     speed = s;
     engine.setSpeed(speed);
   }
   
   synchronized float getSpeed() {
     return speed;
   }
   
    synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   //Free all objects created from Pd4P3 lib
   void free() {
    
     engine.free();
     
   }
   
 }
