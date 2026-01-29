import com.pdplusplus.*;

/*
This is a single table granulator that uses a delay line
It emulates RJDJ's pure data example mostly
There are several parameters to consider:
grain size
grain rate
delay time
bandwdith
volume
phase
panning
The granulator uses a single phasor to read through 
our delay line and shaped by a raised cosine.  That is
how we get our "grain".  You can experiment with various
parameters, see the draw() method for an example. 

There is also a way to randomize these parameters, look
at the Granulator class for something like setDelayRand(400), etc.

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
   String path = this.dataPath("voice.wav");
   //String path = this.dataPath("gong.wav");
   music.readFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(0);
   stroke(255);
   strokeWeight(2);
   noFill();
   textSize(32);
   fill(153);
   
   output = music.getOutput();
   
   double rate, size, bw;
   rate = map(mouseX, 0, width, 5, 25);
   size = map(mouseX, 0, width, 100, 400);
   bw = map(mouseX, 0, width, 1, 3);
   music.setGrain(rate, size, bw);
   
   double del, vol;
   del = map(mouseY, height, 0, 100, 500);
   vol = map(mouseY, height, 0, .4, .8);
   music.setDelay(del, vol);
   
   String s1 = "rate: " + (float)rate + " | size: " + (float)size + 
               " | bw: " + (float)bw;
   text(s1, 10, height/5);
   String s2 = "delay: " + (float)del + " | vol: " + (float)vol;
   text(s2, 10, height/3);
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
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   SoundFiler wav = new SoundFiler();
   Granulator granulator = new Granulator();
   double[] soundFile;
   double fileSize;
   int counter = 0;
   int blockCounter = 0;
   int block = 1024; //change this to bigger or smaller to get better graphing
   float[] writeOutput = new float[block];
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double [] output = new double[2];
     output = granulator.perform(soundFile[counter++]);
     outputL = output[0];
     outputR = output[1]; 
     if(counter == fileSize) counter = 0;
     //our ring buffer
     writeOutput[blockCounter++] = (float)outputL;
     
     if(blockCounter == block)
     {
       setOutput(writeOutput);
       blockCounter = 0;
     }
   }
   
   synchronized void readFile(String file) {
     fileSize = wav.read(file);
     soundFile = wav.getArray(); 
     println("soundFile size = " + soundFile.length);
   }
  
  //This will come from our X-axis
  synchronized void setGrain(double rate, double size, double bw) {
     granulator.setGrainRate(rate);
     granulator.setSize(size);
     granulator.setBandwidth(bw);
  }
  
  //This will come from our Y-axis
  synchronized void setDelay(double del, double vol) {
     granulator.setDelay(del);
     granulator.setVol(vol);
  }
  
  synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     
   }
   
 }
