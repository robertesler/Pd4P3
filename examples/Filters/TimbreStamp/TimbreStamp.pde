import com.pdplusplus.*;

/*
This is an example of timbre stamp convolution.  
I recreated the same timbre stamp example from Pure Data   You can use
any uncompressed audio files you like.

The x-axis adjusts the squelch.  See below for more.
*/

 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);

  //Change these to your own uncompressed audio file paths
   String f1 = dataPath("voice.wav");
   String f2 = dataPath("gong.wav");
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
   The filter input, or 1st arg, is the main "input", the control
   input, 2nd arg, is the stamp.  You can try switching them and 
   see what happens.
   
   The squelch kind of acts like raw compression of the filter input.
   
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
          if(index == fileSize) index = 0;//loop
      }
      
     //our second sound file
     if(index2 != fileSize2)
      {
          bell = (float)( soundFile2[index2++]  ) * .5;
          if(index2 == fileSize2) index2 = 0;//loop
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
