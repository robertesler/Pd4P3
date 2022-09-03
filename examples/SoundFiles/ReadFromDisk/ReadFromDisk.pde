import com.pdplusplus.*;

/*
  This sketch uses ReadSoundFile which reads an uncompressed audio file
  directly from disk in small chunks from a buffer.  It has a much smaller
  memory footprint than SoundFiler but is potentially slower and more CPU
  intensive.  
  
  This class reads audio file formats such as: .wav, .aif, .mat, .au or .raw
  
  You should call open() first, then start(), then stop() if you want.  Your sketch
  will crash if you try to start() or stop() before calling open();
  
  ReadSoundFile is currently in alpha development.

*/

 Pd pd;
 MyMusic music;

boolean stop = true;


 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   music.openSoundFile();//open the sound file
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
 }
 
 void mousePressed() {
  //This protects against a crash by trying to stop a file not already opened.
   if(stop)
  {
     music.stopSoundFile(); 
     stop = false;
  }
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   Read a sound file directly from disk, as a stream, using ReadSoundFile.
 */
 class MyMusic extends PdAlgorithm {
   
   ReadSoundFile readsf = new ReadSoundFile();
   double[] out = new double[2];
   int bufferSize = 10;
   
   void runAlgorithm(double in1, double in2) {
     
     if(!readsf.isComplete())
     {
        out = readsf.start();
        outputL = out[0];
        outputR = out[1];
     }
     else
     {
        outputL = 0;
        outputR = 0;
     }
   }
  
  /*
    You need the direct path to open an uncompressed audio file.  On Windows
    use the format below.  On MacOS or Linux use the standard format like:
    /usr/local/bin or /Users/&&&/Desktop/, etc.
    
    You can also provide a second argument to read into a file using an onset. 
    The onset is in milliseconds.
  */
  void openSoundFile() {
       String path = dataPath("gong.wav");
       readsf.open(path); 
     //readsf.open(path, 800); 
  }
  
  //This will terminate the reading of the file.  Call open() before start();
  void stopSoundFile() {
      readsf.stop();
  }
  
  /* You can change the read buffer size if you like.  
     It is in bits, so 2^x.  Default is 10 bits, or 1024. 
  */
   synchronized void setBufferSize(int f1) {
       readsf.setBufferSize(f1);
   }
   
   synchronized int getbufferSize() {
       return readsf.getBufferSize();
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
       ReadSoundFile.free(readsf); 
   }
   
 }
