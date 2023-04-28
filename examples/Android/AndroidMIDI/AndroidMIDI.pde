import com.pdplusplus.*;
import android.content.pm.PackageManager;
import android.content.Context;
import android.media.AudioManager;
import android.media.midi.*;
import android.os.Bundle;

import android.os.Handler;
import android.os.Looper;
/*
MIDI Template
*/

//declare Pd Android to run in Android mode
 PdAndroid pd;
 MyMusic music;
 MIDI midi;
 boolean touchIsOn = false;
 int midiPort = -1;
 
 void setup() {
  fullScreen();
  noStroke();
  fill(0); 
  orientation(LANDSCAPE);
  
  //We allocate MyMusic first because PdAndroid requires an instance of PdAlgorithm
   music = new MyMusic();
   pd = new PdAndroid(music);
   midi = new MIDI();
   midi.list(this.getContext());
   midi.start(this.getContext(), midi);
   //midi.start(this.getContext(), midi, 0, 0);
  
  //You must ask for microphone permissions before starting
   if(isRecordPermissionGranted())
    {
      //We store the mic permissions so we can check later if needed.
      pd.setInputPermissions(isRecordPermissionGranted());
      pd.start();
      new Thread(pd).start();
    }
   else 
    {
      requestRecordPermission();
      pd.setInputPermissions(isRecordPermissionGranted());
      pd.start();
      new Thread(pd).start();
    }
  
 }
 
 //This is still in testing mode.  The home button doesn't seem to be handled formally.
 void backPressed() {
   exit();
 }

 void draw() {
  
    background(255);
    String s1 = midi.midiString;
    String s2 = midi.midiCCString;
    String s3 = midi.midiPitchBendString;
    String s4 = midi.midiAftertouchString;
    String [] d = midi.myDevices;
    textSize(100);
    text(s1, 40, 120);
    text(s2, 40, 240);
    text(s3, 40, 360);
    text(s4, 40, 480);
    textSize(64);
    for(int i = 0; i < d.length; i++)
    {
       text(d[i], 40, height - (i+1)*120); 
    }
    
    /*
    //testing this for future use
    if(touchIsOn)
    {
      for(int i = 0; i < touches.length; i++)
      {
        if(touches[i].x < width/2 && touches[i].y < height && touches[i].y > height - 120)
        {
          midiPort = 0;
          println("Touch me! " + 0);
        }
        if(touches[i].x < width/2 && touches[i].y < height-120 && touches[i].y > height - 250)
        {
          midiPort = 1;
          println("Touch me! " + 1);
        }
      }
    }
    */
    
 }
 
 void touchStarted() {
   touchIsOn = true;
 }
 
 void touchEnded() {
   touchIsOn = false;
   if(midiPort != -1)
   {
     //midi.start(this.getContext(), midi, midiPort, 0);
   }
 }
  
 //We have to deallocate memory in the Pd4P3 native lib before we leave. 
 public void onDestroy() {
   super.onDestroy();
   if(pd.isPlaying() == true)
     pd.stop();
   pd.free();
   midi.stop();
}
 
 //Our permission routines
 public boolean isRecordPermissionGranted() {
        return hasPermission("android.permission.RECORD_AUDIO");
    }

 private void requestRecordPermission(){
        requestPermission("android.permission.RECORD_AUDIO"); 
    } 

  /*
  Everything else in Android mode is exactly the same as in Java mode.
  Create a new class that extends PdAlgorithm, and go about normal 
  digital signal processing.
  
  */  

class MyMusic extends PdAlgorithm {
   
   //create new Pd4P3 objects like this
   Oscillator osc = new Oscillator();//for vibrato
   int max = 8;
   Synth synths[] = new Synth[max];
   double out = 0;
   int frameCounter = 0;
   
   int [] notes = new int[max];    
   int [] vels = new int[max];
   int [] voices = new int[max];
    
   int controlChange = 0;
   double numOfVoices = 0;
   
    MyMusic() {
     
     for(int i = 0; i < max; i++)
         synths[i] = new Synth(); 
      
   }
    
    
   //All DSP code goes here, the in1, in2 variables are from the microphone input.
   void runAlgorithm(double in1, double in2) {
     
     double out = 0;
     double v = midi.getNumOfVoices();
     double mix = .3;
     double cf = (double)midi.getControlChange()/127.0f;
     cf *= 20;
     double at = (double)midi.getAftertouch()/127.0f; //TODO: use this for something.  
    
     double vibrato;
     notes = midi.getNotes();
     vels = midi.getVelocities();
     voices = midi.getVoices();
     
     //Add simple vibrato using the modulation wheel
     if(cf > 0)
       vibrato = (osc.perform(cf) * .6) + .6;
     else
       vibrato = 1;
    
     //A cheap and dirty way to mix our signals
     if(v > max-2)
         mix = .2;
     
     //This will check for new MIDI events every 64 samples. You could also use pd.getBlockSize()
     if(frameCounter > 64)
     {
       try {
        midi.processMidiEvents(); 
       }
       catch(IOException e) {
          println("MIDI Exception: " + e); 
       }
       
       frameCounter = 0;
     }
     
     frameCounter++;
      
     //Sum our synths 
     for(int i = 0; i < max; i++)
     {
        double f = pd.mtof(notes[i]);
        double amp = (double)vels[i]/127.0f;
        f *= midi.getPitchBend();
        out += synths[i].perform(f, amp*mix, voices[i] == -1?false:true);
     }
    
     outputL = outputR =  out * vibrato ;
    
   }
 
  //Free any Pd4P3 objects you create here.
   void free() {
     Oscillator.free(osc);
     for(int i = 0; i < max; i++)
     {
        synths[i].free(); 
     }
   }
   
 }
 
 
 /*
  
 */
