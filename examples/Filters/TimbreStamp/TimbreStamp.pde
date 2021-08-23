import com.pdplusplus.*;

/*
This is an example of timbre stamp convolution.  
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);

  ;
   String f1 = "C:\\Users\\&&&\\Desktop\\voice.wav";
   String f2 = "C:\\Users\\&&&\\Desktop\\bell.aiff";
   music.openSoundFile(f1, f2);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
   float s = map(mouseX, 0, width, 1, 75);
   music.setSquelch((int)s);  
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
   
   Convolution conv = new Convolution(1024, 4);
   SoundFiler wav = new SoundFiler();

   //Sound File Stuff
   double[] soundFile;
   double[] soundFile2;
   double fileSize;
   double fileSize2;
   int index = 0;
   int index2 = 0;
   
   //This will read our sound file, send it to our convolution class with our synth input
   void runAlgorithm(double in1, double in2) {
      float voice = 0;
      float bell = 0;
      //double input = (in1 + in2)*.5;//our mic input
      
      //This our uncompressed mono soundfile input, it is set to loop
      if(index != fileSize)
      {   
          voice = (float)( soundFile[index++] ) * .5;
          if(index == fileSize) index = 0;
      }
      
     //our second sound file
     if(index2 != fileSize2)
      {
          bell = (float)( soundFile2[index2++]  ) * .5;
          if(index2 == fileSize2) index2 = 0;
      }
      
      
     outputL = outputR = conv.perform(bell, voice);
     
   }
   
   
   void openSoundFile(String file, String file2) {
      fileSize = wav.read(file);
      soundFile = wav.getArray(); 
      fileSize2 = wav.read(file2);
      soundFile2 = wav.getArray();
   }

   
   synchronized void setSquelch(int sq) {
      conv.setSquelch(sq); 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     Convolution.free(conv);
   }
   
 }
