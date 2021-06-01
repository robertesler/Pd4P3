import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 //Change your file path to your .wav or .aiff audio file
 String file = "C:\\Users\\rwe8\\Documents\\Processing\\libraries\\Pd4P3\\examples\\SoundFiles\\SoundFile\\Bach.wav";
 
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
   This is where you should put all of your music/audio behavior and DSP
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
     
     //loop an audio file
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
