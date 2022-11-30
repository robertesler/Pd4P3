
/*
This examples shows you how to load sound files from the /data folder.
In Android mode, the /data folder is copied to the Android /assets folder.
This folder is used to hold various images, text files, xml files, and can
also contain audio files.  

To make this work with Pd4P3 we need to extract the resource first from the 
apk.  See: 
public static File extractAsset(InputStream in, String filename, File directory)

Then we get the absolute directory using: File.getAbsolutePath()

Finally we pass that string to the SoundFiler class.  

This is different from Java mode, so your sketches won't work directly on the 
Processing side.  

Everything should remain the same on the Pd4P3 side however.  Notice how our
MyMusic class is identical to the PlaySoundFile.pde example.

NOTE: Keep in mind that trying to load lots of large files from the cache may cause problems
with the Android OS.  See: https://developer.android.com/reference/android/content/Context#getCacheDir()
for more information.  
If you need to load lots of large audio files, look into loading them from external storage.  

*/
import com.pdplusplus.*;
import android.util.Log;
import android.content.res.AssetManager;

import android.content.Context;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

//declare Pd Android when you run in Android mode
 PdAndroid pd;
 MyMusic music;
 
void setup() {
  
  fullScreen();
  noStroke();
  fill(0);
  music = new MyMusic();
  pd = new PdAndroid(music);
  
   //You must ask for microphone permissions before starting
  // requestRecordPermission();
   if(isRecordPermissionGranted())
    {
      String path = "";
      File audioFile = null;
      println("permission is granted!");
      try {
              Context context = getContext();  
              AssetManager assets = context.getAssets();
              InputStream in = assets.open("Bach.wav");
              audioFile = extractAsset(in, "Bach.wav", context.getCacheDir());
              if(!audioFile.exists())
              {
                  throw new FileNotFoundException(audioFile.getPath());
              }
          } catch (IOException e) {
              e.printStackTrace();
              exit();
          }
      
      path = audioFile.getAbsolutePath();
      println(path);
      music.readFile(path);
      pd.setInputPermissions(isRecordPermissionGranted());
      pd.start();
      new Thread(pd).start();
    }
   else 
    {
      println("Permission DENIED!");
      requestRecordPermission();
      String path = "";
      File audioFile = null;
      println("permission is granted!");
      try {
              Context context = getContext();  
              AssetManager assets = context.getAssets();
              InputStream in = assets.open("Bach.wav");
              audioFile = extractAsset(in, "Bach.wav", context.getCacheDir());
              if(!audioFile.exists())
              {
                  throw new FileNotFoundException(audioFile.getPath());
              }
          } catch (IOException e) {
              e.printStackTrace();
              exit();
          }
      
      path = audioFile.getAbsolutePath();
      println(path);
      music.readFile(path);
      pd.setInputPermissions(isRecordPermissionGranted());
      pd.start();
      new Thread(pd).start();
    }
  
}

void draw() {
  
 background(204);
  if (touchIsStarted) {
    if (mouseX < width/2) {
      music.setPlaying(true);
      fill(0);
      rect(0, 0, width/2, height); // Left
    } else {
      music.setPlaying(false);
      fill(0);
      rect(width/2, 0, width/2, height); // Right
    }
  } 
  
}

 //This is still in testing mode.  
 void backPressed() {
   exit();
 }

 public void onDestroy() {
   super.onDestroy();
   if(pd.isPlaying() == true)
     pd.stop();
   pd.free();
}

/*Taken from libpd for android code. IoUtils.java
  It manually extracts a file from the filesystem cache.
*/
public static File extractAsset(InputStream in, String filename, File directory)
            throws IOException {
        int n = in.available();
        byte[] buffer = new byte[n];
        in.read(buffer);
        in.close();
        File file = new File(directory, filename);
        FileOutputStream out = new FileOutputStream(file);
        out.write(buffer);
        out.close();
        return file;
    }
 
 //Our permission routines
 public boolean isRecordPermissionGranted() {
        return hasPermission("android.permission.RECORD_AUDIO");
    }

 private void requestRecordPermission(){
        requestPermission("android.permission.RECORD_AUDIO"); 
    }

 
 /*
   On Android this is all basically the same as Pd4P3 on Mac/Win/Linux.
   
   This is where you should put all of your music/audio behavior and DSP
 */


class MyMusic extends PdAlgorithm {
   
   SoundFiler wav = new SoundFiler();
   
   double[] soundFile;
   double fileSize;
   int counter = 0;
   boolean play = true;
   
   /*This reads the data from our audio into an array.  Data now exists in RAM.  
   If you want stream the data from disk look into the ReadSoundFile class.
   */
   void readFile(String file) {
    
     try {
    fileSize = wav.read(file);
     }
     catch(Exception e) {
        printStackTrace(e); 
     }
    soundFile = wav.getArray(); 

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
     
     if(play)
     {
       if(counter != fileSize)
       {
          outputL = soundFile[counter++];
          outputR = soundFile[counter++];
          if(counter == fileSize) counter = 0;
       }
     }
      
   }
  
  //We call this from the draw() method to start and stop the audio.
    synchronized void setPlaying(boolean stop) {
       play = stop; 
    }
    
  
   //Free all objects created from Pd4P3 lib
   void free() {
     SoundFiler.free(wav);
     
   }
   
 }
