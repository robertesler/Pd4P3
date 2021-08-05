import com.pdplusplus.*;
/*
This sketch will demonstrate how to write a sound file 
directly to disk.  This is in contrast to the SoundFiler
class which writes from an array then to disk.

The WriteSoundFile class will write directly to disk in
small chunks and not stop until you tell it to.  This of
course allows to record as long you like and not have to
specify the length of the file like in SoundFiler.

Pd4P3 currently only supports uncompressed audio formats like
.wav, .aif, .mat, .au or .raw.  

WriteSoundFile is currently in alpha, there may be bugs.
Please report at https://github.com/robertesler/Pd4P3/issues
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq1 = 100;
 int start = -1;
 String s = "Not recording";

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
  music.setSoundFile();//open our file to write
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
  freq1 = map(mouseX, 0, width, 100, 800);
  music.setFreq(freq1);
  
  if(start == 0)
  {
    
    s = "Recording";
    music.setStart(start);
    
  }
  if(start == 1)
  {
    s = "Stopped";
    music.setStart(start);
    music.stopSoundFile();
  }
  
  if(start > 1)
  {
     s = "END"; 
  }
  fill(50);
  text(s, 10, 10, 100, 100);
 }
 
 void mousePressed() {
   start++;
   
 }
 
 public void dispose() {
   //stop Pd engine
   if(start == 0)
     music.stopSoundFile();
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   Write your uncompressed audio directly to disk using WriteSoundFile
 */
 class MyMusic extends PdAlgorithm {
   
   WriteSoundFile writesf = new WriteSoundFile();
   Oscillator osc = new Oscillator();
   Noise noise = new Noise();
   int channels = 2;//stereo file
   double[] out = new double[channels];//this will be what we send to writesf
   float freq = 100;
   int start = -1;
   
   void runAlgorithm(double in1, double in2) {
     outputL = osc.perform(getFreq()) * .5; 
     outputR = noise.perform() * .25;
     
     if(getStart() == 0)
    {
     //Now lets write what we hear to the file on disk
     out[0] = outputL;//write left channel
     out[1] = outputR;//write right channel
     writesf.start(out);
    }
   }
   
   /*You will need to specify the direct path, so ../../../test.wav
     won't work currently.  For Windows remember to use C:\\Users\\
     format, for MacOS or Linux use the standard path format e.g. 
     /usr/local/bin or /Users/&&&/Desktop/, or whatever...
     You must always call open() before start()
   */
   void setSoundFile() {
    writesf.open("C:\\Users\\***\\Desktop\\Test.wav", channels);
    //You can also specify different uncompressed formats and bit depths, see docs for more
    //writesf.open("C:\\Users\\&&&\\Desktop\\Test.wav", channels, FILE_AIF, STK_SINT24);
   }
   
   /*
   This will stop writing the file to disk and close the file for read access.
   */
   void stopSoundFile() {
     writesf.stop(); 
   }
   
   synchronized void setStart(int s) {
     start = s;
   }
  
  synchronized int getStart() {
     return start;
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     WriteSoundFile.free(writesf);
     Oscillator.free(osc);
     Noise.free(noise);
   }
   
 }
