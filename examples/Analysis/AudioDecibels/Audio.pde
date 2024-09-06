 /*
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   SoundFiler wav = new SoundFiler();
   Envelope env = new Envelope();
   
   double[] soundFile;
   double fileSize;
   int counter = 0;
   float volume = 1;
   double decibels = 0;
   
   void readFile(String file) {
    fileSize = wav.read(file);
    soundFile = wav.getArray(); 
     println("soundFile size = " + soundFile.length);

   }
   
   
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     /* loop a stereo audio file, if using a mono file 
     use outputL = outputR = soundFile[counter++] * getVolume();
     */

      if(counter != fileSize)
      {
          outputL = soundFile[counter++] * getVolume();
          outputR = soundFile[counter++] * getVolume();
          if(counter == fileSize) counter = 0;
          decibels = env.perform( (outputL + outputR) *.5);
      }
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setVolume(float v) {
     volume = v;
   }
   
   synchronized float getVolume() {
     return volume;
   }
   
   synchronized double getDecibels() {
     return decibels;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     Envelope.free(env);
   }
   
 }
