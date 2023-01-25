import com.pdplusplus.*;

/*
MIDI Template
*/

//declare Pd Android to run in Android mode
 PdAndroid pd;
 MyMusic music;
 MIDI midi;
 
 void setup() {
  fullScreen();
  noStroke();
  fill(0); 
  orientation(LANDSCAPE);
  
  //We allocate MyMusic first because PdAndroid requires an instance of PdAlgorithm
   music = new MyMusic();
   pd = new PdAndroid(music);
   midi = new MIDI();
   
   midi.startMIDI(this.getContext());
   
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
    String s = "Note: " + String.valueOf(midi.note) + " | " + String.valueOf(midi.velocity);
    textSize(128);
    text(s, 40, 120);
 }
 
  
 //We have to deallocate memory in the Pd4P3 native lib before we leave. 
 public void onDestroy() {
   super.onDestroy();
   if(pd.isPlaying() == true)
     pd.stop();
   pd.free();
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
   Oscillator osc = new Oscillator();
   
    double out = 0;
    
   //All DSP code goes here, the in1, in2 variables are from the microphone input.
   void runAlgorithm(double in1, double in2) {
     
     double f = pd.mtof(midi.note);
     double amp = (double)midi.velocity/127.0f;
     outputL = outputR = osc.perform(f) * amp;
    
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setVar(double f1) {
     out = f1;
   }
   
   synchronized double getVar() {
     return out;
   }
 
  //Free any Pd4P3 objects you create here.
   void free() {
     Oscillator.free(osc);
   }
   
 }
