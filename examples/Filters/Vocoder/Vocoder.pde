import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   pd.setFFTWindow(512);//our window size

   music.createHann();
   String f1 = "C:\\Users\\rwe8\\Desktop\\bell.aiff";
   String f2 = "C:\\Users\\rwe8\\Desktop\\voice.wav";
   music.openSoundFile(f1, f2);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
   float s = map(mouseX, 0, width, 1, 75);
   music.setSquelch((int)s);
   
   if(keyPressed)
   {
      if(key == '1')
      {
        music.setFreq((float)music.mtof(60));
      }
      if(key == '2')
      {
        music.setFreq((float)music.mtof(62));
      }
      if(key == '3')
      {
        music.setFreq((float)music.mtof(63));
      }
      if(key == '4')
      {
        music.setFreq((float)music.mtof(65));
      }
      if(key == '5')
      {
        music.setFreq((float)music.mtof(67));
      }
      if(key == '6')
      {
        music.setFreq((float)music.mtof(68));
      }
      if(key == '7')
      {
        music.setFreq((float)music.mtof(70));
      }
      if(key == '8')
      {
        music.setFreq((float)music.mtof(72));
      }
      
   }
   
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
   
   Convolution convolution = new Convolution();
   Synth synth = new Synth();
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
      float input = 0;
      float control = 0;
      //input = (in1 + in2)*.5;//our mic input
      //control = (float)synth.perform();
      
      //This our uncompressed mono soundfile input, it is set to loop
      if(index != fileSize)
      {   
          input = (float)( soundFile[index++] ) * .5;
          if(index == fileSize) index = 0;
      }
     //our second sound file
     if(index2 != fileSize2)
      {
          control = (float)( soundFile2[index2++]  ) * .5;
          if(index2 == fileSize2) index2 = 0;
      }

     outputL = outputR = convolution.perform(input, control);
     
   }
   
   void createHann() {
    
     convolution.createHann(this.getFFTWindow());
   }
   
   void openSoundFile(String file, String file2) {
      fileSize = wav.read(file);
      soundFile = wav.getArray(); 
      fileSize2 = wav.read(file2);
      soundFile2 = wav.getArray();
   }

   synchronized void setFreq(float f) {
        synth.setFreq(f);
   }
   
   synchronized void setSquelch(int sq) {
      convolution.setSquelch(sq); 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     synth.free();
     convolution.free();
   }
   
 }
