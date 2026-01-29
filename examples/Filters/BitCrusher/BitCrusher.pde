import com.pdplusplus.*;

/*
A simple bit crusher example.  We take
our bit depth and multiply it by our signal
then we get our the decimal portion of the signal
and subtract it from the original, and the apply 
the gain correction. 

The signal is graphed to the window so you can see the 
artifiacts for each depth.

x-axis = bit depth
y-axis = mix between original and bit crushed

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
   //You can try two different samples for fun!
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
   
   float bit = map(mouseX, 0, width, 2, 25);
   music.setBitDepth((int)bit);
   float x = map(mouseY, height, 0, 90, -1);
   music.setCrossFade(x);
   String s = "bits: " + (int)bit + " | crossfade: " + x;
   textSize(32);
   fill(153);
   text(s, width/4, height/4);
   
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
 
 class MyMusic extends PdAlgorithm {
   
  SoundFiler wav = new SoundFiler();
  HighPass [] hip = new HighPass[2]; 
   double[] soundFile;
   double fileSize;
   int counter = 0;
   int blockCounter = 0;
   int bit = 2;
   float crossfade = 0;
   int block = 1024; //change this to bigger or smaller to get better graphing
   float[] writeOutput = new float[block];
   
   public MyMusic() {
      hip[0] = new HighPass();
      hip[1] = new HighPass();
      hip[0].setCutoff(4);
      hip[1].setCutoff(4);
   }
   
   synchronized void readFile(String file) {
     fileSize = wav.read(file);
     soundFile = wav.getArray(); 
     println("soundFile size = " + soundFile.length);
   }
   
   void runAlgorithm(double in1, double in2) {
      
      double sf = hip[0].perform(soundFile[counter++]);
      double a = sf * max(1, getBitDepth());
      double b = wrap(a);
      double c = (a - b) * (float)(1/(float)getBitDepth());
      double d = crossfade(hip[1].perform(c), sf, getCrossFade());
      outputL = outputR = d * .5;
      if(counter == fileSize) counter = 0;
      
     //our ring buffer
     writeOutput[blockCounter++] = (float)outputL;
     
     if(blockCounter == block)
     {
       setOutput(writeOutput);
       blockCounter = 0;
     }
      
   }
   
   public int getBitDepth() {
     return bit;
   }
   
   synchronized void setBitDepth(int bd) {
     bit = bd;
   }
   
   public float getCrossFade() {
      return crossfade; 
   }
   
   synchronized void setCrossFade(float x) {
      crossfade = x * .01;
   }
   
   public double max(double a, double b) {
     double max = 0;
     if(a < b) max = b;
     if(a > b) max = a; 
     return max;
   }
   
   //Returns only the decimal portion of a number
   public double wrap(double in) {
     double out = 0;
     int k;
     double f = in;
     f = ((f > Integer.MAX_VALUE || f < Integer.MIN_VALUE) ? 0. : f);
     k = (int)f;
     if( k <= f)
       out = f-k;
     else
       out = f - (k-1);
       
     return out;
    }
    
    private double crossfade(double a, double b, double x) {
        return a + (x * (b - a));
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
     HighPass.free(hip[0]);
     HighPass.free(hip[1]);
     
   }
   
 }
