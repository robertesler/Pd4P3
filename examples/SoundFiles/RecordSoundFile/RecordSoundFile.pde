import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  freq = map(mouseX, 0, width, 200, 1000);
  music.setFreq(freq);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This will record your audio output.  Not fit for long recordings, this 
   writes into RAM then saves to disk.
 */
 class MyMusic extends PdAlgorithm {
   
   Noise noise = new Noise();
   BandPass bp = new BandPass();
   SoundFiler wav = new SoundFiler();
   int size = (int)this.getSampleRate() * 8;//4 seconds of audio * 2 channels
   double[] sound = new double[size];
   String fileName = "C:\\Users\\***\\Desktop\\Pd4P3_test.wav";
   int sampleCounter = 0;
   float freq = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     bp.setCenterFrequency(getFreq());
     double out = bp.perform(noise.perform());
    
     //We store our output to an array to write later
     if(sampleCounter < size)
     {
       sound[sampleCounter] = out;
     }
     
     outputL = outputR = out; 
    
     if(sampleCounter == size)
     {
       stopWrite();
     }
     
      sampleCounter++; 
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   private void stopWrite()  {
      /* 
     The write method needs a file name, channel #, type, format and array.
     The file type and format are documented in the SoundFiler class
     This creates a 32-bit float wav file
     */
     wav.write(fileName, 2, wav.FILE_WAV, wav.STK_FLOAT32, sound);
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
    
     Noise.free(noise);
     BandPass.free(bp);
     SoundFiler.free(wav);
     
   }
   
 }
