import com.pdplusplus.*;

/*
  This sketch demonstrates an octave doubler.  An effect where
  a sound file or mic input is pitched up an octave using the 
  phase difference between two delays.
*/

 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   music.setSigmund();
   String path = dataPath("voice.wav");
   music.openSoundFile(path);
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This class imitates the Octave Doubling example from Pd G06.octave.doubler.pd
 */
 class MyMusic extends PdAlgorithm {
   
   VariableDelay vd = new VariableDelay();
   VariableDelay vd2 = new VariableDelay();
   Sigmund sigmund = new Sigmund("pitch", "env");
   Line line = new Line();
   SoundFiler wav = new SoundFiler();
   SigmundPackage sigPack;
   double pitch = 100;
   int numOfPoints = 2048;
   double fileSize;
   double[] soundFile;
   int counter = 0;
   
   /*
     Here we use the Variable Delay as a tuned comb filter tuned
     one octave higher (500/pitch) + delTime1.  We then have a fixed
     delay that is to the window size of Sigmund.  When added together
     this cancels out the odd harmonics, so this only lets the pitched
     up even harmonics through. 
     
     This is known as octave doubling.
   */
   void runAlgorithm(double in1, double in2) {
      
      double input = 0;
     //input = (in1 + in2) *.5;
     
     //THis reads a mono sound file from RAM
      if(counter != fileSize)
      {
          input = soundFile[counter++];
          //loop the file
          if(counter == fileSize) counter = 0;
      }
     
     //Get our fundamental pitch
     sigPack = sigmund.perform( input );
     
     //Filter out the zeros from the stream
     if(this.mtof(sigPack.pitch) > 0)
       pitch = this.mtof(sigPack.pitch);
    
     //our stable delay, 1 window length     
     double delTime1 = (numOfPoints*1000)/this.getSampleRate();
     //our variable delay time, 1/2 cycle + 1 window length
     double delTime2 = 500/pitch + delTime1;
     //write our delay
     vd.delayWrite(input);
     vd2.delayWrite(input);
     double d1 = vd2.perform(delTime1);
     //here we use Line to smooth between changes in value
     double d2 = vd.perform( line.perform(delTime2, 20) );
     outputL = outputR = d1 + d2 ; //add the delays together
     
   }
   
   public void setSigmund() {
      sigmund.setNumOfPoints(numOfPoints);
   }
   
  public void openSoundFile(String s) {
     fileSize = wav.read(s);
     soundFile = wav.getArray();
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     VariableDelay.free(vd);
     VariableDelay.free(vd2);
     Line.free(line);
     Sigmund.free(sigmund);
     SoundFiler.free(wav);
     
   }
   
 }
