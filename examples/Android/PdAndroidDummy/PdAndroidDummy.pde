import com.pdplusplus.*;

/*
Dummy Template for Pd4P3 Android Mode. Use this to set up new projects.
There are some minor differences between Java and Android mode.  
The big one is you have to ask for microphone permissions, and 
set the permissions to RECORD_AUDIO in the AndroidManifest.xml. 
See the Android menu in P4.

The microphone input is most likely a single input, not stereo.  In the java class
PdAndroid I have just set the second input to 0 as to not to have to hassle with
checking everytime if in the rare chance your phone or tablet has a stereo mic 
array.  If you are trying to use an external mic you may have to update this
class to fit your needs.
*/

//declare Pd Android to run in Android mode
 PdAndroid pd;
 MyMusic music;
 
 
 void setup() {
  fullScreen();
  noStroke();
  fill(0); 
  orientation(PORTRAIT);
  
  //We allocate MyMusic first because PdAndroid requires an instance of PdAlgorithm
   music = new MyMusic();
   pd = new PdAndroid(music);
   
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
   // Oscillator osc1 = new Oscillator();
   
    double out = 0;
    
   //All DSP code goes here, the in1, in2 variables are from the microphone input.
   void runAlgorithm(double in1, double in2) {
     
     outputL = outputR = out;
    
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
     //Oscillator.free(osc);
   }
   
 }
