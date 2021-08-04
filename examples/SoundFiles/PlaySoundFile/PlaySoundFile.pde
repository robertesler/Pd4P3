import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 //Change your file path to your .wav or .aiff audio file
 String file = "C:\\Users\\***\\Documents\\Processing\\libraries\\Pd4P3\\examples\\SoundFiles\\SoundFile\\Bach.wav";
 
 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   music.readFile(file);
   
   pd = Pd.getInstance(music);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
  String s = "Prelude in C-minor by J.S Bach";
fill(50);
text(s, 10, 10, 80, 80);  // Text wraps within text box
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is an example of how to read an audio file into RAM.  SoundFiler only reads uncompressed file formats
   such as .wav, .aif, or raw formats.  See the code documentation here: https://github.com/robertesler/Pd4P3/blob/main/src/com/pdplusplus/SoundFiler.java
   for more details.  
   You must also provide the direct path of the file, see the example above for Windows.  Linux or MacOS use
   the standard UNIX path system.
 */
 
 class MyMusic extends PdAlgorithm {
   
   SoundFiler wav = new SoundFiler();
   
   double[] soundFile;
   double fileSize;
   int counter = 0;
   
   void readFile(String file) {
    fileSize = wav.read(file);
    soundFile = wav.getArray(); 
     println("soundFile size = " + soundFile.length);
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     /*loop a stereo audio file, stereo audio files are interleaved so soundFile[0] is the left channel
       and soundFile[1] is the right channel and so forth.  If your file is mono just use something like:
       outputL = outputR = soundFile[counter++];
       If you have multiple channel output greater than stereo you could use a loop but you would also have
       to change the Pd.java to accept more than two outputs.  If you require that kind of functionality contact
       the author of Pd4P3 for help.
     */
      if(counter != fileSize)
      {
          outputL = soundFile[counter++];
          outputR = soundFile[counter++];
          if(counter == fileSize) counter = 0;
      }
   }
  
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     
   }
   
 }
