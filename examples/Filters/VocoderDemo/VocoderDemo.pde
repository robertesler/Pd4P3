import com.pdplusplus.*;

/*
This sketch shows how to create a simple, crude, vocoder.
You can control the synthesizer using the X/Y coordinates of
the mouse.  

The display shows you the amplitude of each band in the filter bank.

Change the path below to a mono, uncompressed audio file (.wav or .aiff).
I used the voice.wav from Pure Data.
*/

 Pd pd;
 MyMusic music;
 
double[] tab;
double[] smooth;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   tab = new double[music.getNumOfFilters()];
   smooth =  new double[music.getNumOfFilters()];
   String path = dataPath("voice.wav");
   music.setAudioFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   
   background(210, 210, 210);
   tab = music.getEnvTable();
   float f = map(mouseX, 0, width, 50, 200);
//   float index = map(mouseY, 0, height, 200, 50);
   music.setFreq(f);
  
   fill(0);
   String s = "Hz: " + str(f) ;
   text(s, 50, 50);
  
   fill(0, 100, 200);
   noStroke();
    
    //This is a simple RTA display
   for(int i = 0; i < music.getNumOfFilters(); i++)
    {
      float x, y, w, h;
      smooth[i] += (tab[i] - smooth[i]) * .6;
      w = width/(music.getNumOfFilters() * .5);
      x = w * i;
      h = (float)-smooth[i] * height;
      y = height;
      rect(x, y, w, h);
    }
  
 
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This example will play a mono uncompressed audio file (.wav or .aiff)
   and run it through a crude vocoder.  
 */
 class MyMusic extends PdAlgorithm {
   
   SoundFiler soundfiler = new SoundFiler();
   Vocoder vocoder = new Vocoder();

   double[] audioFile;
   double fileSize;
   int sampleCounter = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     /*
      This our audio file stored into an array.  
      If you have a stereo file just update the
      sampleCounter++ again since .wav and .aiff
      files are interleaved.  
      You would have to convert to mono for the vocoder input.
      For example: 
      double outL, outR;
      outL = audioFile[sampleCounter++];
      outR = audioFile[sampleCounter++];
      double out = (outL + outR) * .5;
     */
     double out = audioFile[sampleCounter++]; 
     if(sampleCounter == fileSize) sampleCounter = 0;
     
     outputL = outputR = vocoder.perform(out); 
     
   }
   
   public void setAudioFile(String f) {
      fileSize = soundfiler.read(f); 
      audioFile = soundfiler.getArray();
      vocoder.setVocoder();
   }
  
   synchronized double[] getEnvTable() {
     return vocoder.getEnvelope();
   }
   
   synchronized int getNumOfFilters() {
      return vocoder.getNumOfFilters(); 
   }
   
   synchronized void setFreq(double f) {
      vocoder.setFreq(f); 
   }
   
   
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(soundfiler);
     vocoder.free();
     
   }
   
 }
