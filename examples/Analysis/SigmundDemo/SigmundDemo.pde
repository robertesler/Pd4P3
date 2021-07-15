import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float[] output;
 float dummyFloat = 1;
 float b = 0;
 double[] freqs = new double[10];
 double[] amps = new double[10];

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
      map(i, 0, output.length, width, 0),
      map(output[i], 1, -1, 0, height)
    );
  }
  endShape();
 
 freqs = music.getFrequencies();
 amps = music.getAmplitudes();
 
 
 for(int i = 0; i < freqs.length; i++)
 {
   float rectX = map((float)freqs[i], 20, 5000, 0, width);
   float rectY = map((float)amps[i], .0001, .3, height/2.25, 0);
   float rectW = map((float)freqs[i], 20, 5000, 20, 70);
   float rectH = map((float)amps[i], .0001, .3, 20, 70);
   float rectColorR = map((float)freqs[i],  20, 5000, 0, 255);
   float rectColorG = map((float)amps[i],  .0001, .3, 0, 255);
   float rectColorB = map((float)amps[i],  .0001, .3, 100, 255);
   fill(rectColorR, rectColorG, rectColorB);
   rect(rectX, rectY, rectW, rectH); 
   
 }
 
  
 
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This example uses Sigmund to analyze the input signal.  Sigmund is
   a very sophisticated analysis tool that can detect pitch, envelope,
   and even the strongest sinusoidal components of a sound.
   This particular sketch gets the "loudest" 10 frequencies of the signal
   then maps them to color and rectangle size in the draw() method.
   
 */
 class MyMusic extends PdAlgorithm {
   
   Analysis analysis = new Analysis();
   Oscillator osc = new Oscillator();
   float dummy = 0;
   int block = 1024;
   int counter = 0;
   float[] writeOutput = new float[block];
   double pitch = 0;
   double envelope = 0;
   double[] frequencies = new double[10];
   double[] amplitudes = new double[10];
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     float f1 = 0, f2 = 0;
     for(int i = 0; i < frequencies.length; i++)
     {
         f1 = map((float)frequencies[i], 20, 6000, 100, 500);
         f2 = map((float)frequencies[i], 20, 6000, 70, 300);
     }
     analysis.perform((in1 + in2) * .5);
     
     //I added a ring modulator for fun here, you can remove it if you prefer.
     outputL = (in1 * (osc.perform(f1) *.35) + .6) + (in1 *.5);
     outputR = (in2 * (osc.perform(f2) *.35) + .6) + (in2 * .5);
     
     
     //our ring buffer for drawing in the P3 thread
     writeOutput[counter++] = (float)(outputL + outputR)*.5;
   
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized double getEnvelope() {
     envelope = analysis.getEnvelope();
     return envelope;
   }
   
   synchronized double getPitch() {
     pitch = analysis.getPitch();
     return pitch;
   }
   
    /*
   We'll use these setters and getters to send our audio data back to the P3 thread for drawing
   */
    synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   
   synchronized double[] getFrequencies() {
      double[][] p = analysis.getPeaks();
      for(int i = 0; i < 10; i++)
      {
         frequencies[i] = p[i][1]; 
      }
      return frequencies;
   }
   
   synchronized double[] getAmplitudes() {
       double[][] a = analysis.getPeaks();
      for(int i = 0; i < 10; i++)
      {
         amplitudes[i] = a[i][2]; 
      }
      return amplitudes;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc); 
     analysis.free();
     
   }
   
 }
