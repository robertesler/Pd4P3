import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq = 200;
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
  freq = map(mouseX, 0, width, 50, 800);
  music.setFreq(freq);
  
   // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  String f = str(freq) + "Hz"; 

  text(f, mouseX, mouseY);
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
 
 void mousePressed() {
   music.setBang(true);
   println("freq: " + freq);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is an example of Karplus-Strong string synthesis
 */
 class MyMusic extends PdAlgorithm {
   
   Noise noise = new Noise();
   VariableDelay vd = new VariableDelay();
   LowPass lop = new LowPass();
   BiQuad biquad = new BiQuad();
   Line line = new Line();
   double[] wavetable;
   boolean bang = false;
   int count = 0;
   double delay = 0;
   float freq = 200;
   int block = 1024;
   int counter = 0;
   float[] writeOutput = new float[block];
   double delTime = 0;
   double env = 0;
   double output = 0;
   double filter = 0;
   
  
   void runAlgorithm(double in1, double in2) {
     
     delTime = 1000/getFreq();
     output = noise.perform() * env;
     
     if(getBang())
     {
        env = line.perform(1, delTime); 
        biquad.setCoefficients(0, 0, 0, 0, 1);//This just is just a 2 sample delay
       //lop.setCutoff(6000);//You can hear the difference with a different filter
     }
     else
     {
       env = line.perform(0, delTime);
     }
     
     if(env == 1)
     {
        setBang(false); 
     }
     
     vd.delayWrite(output + (filter + (delay * .5)) * .994);
     delay = vd.perform(delTime);
     filter = biquad.perform( (delay * .5) );
     //filter = lop.perform( (delay * .5) );
    
     outputL = outputR = delay + output;
     
     //our ring buffer for drawing in the P3 thread
     writeOutput[counter++] = (float)outputL;
     
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
   }
  
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
   
   /*
   We'll use these setters and getters to send our audio data back to the P3 thread for drawing
   */
   synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     VariableDelay.free(vd);
     BiQuad.free(biquad);
     LowPass.free(lop);
     Line.free(line);
     
   }
   
 }
