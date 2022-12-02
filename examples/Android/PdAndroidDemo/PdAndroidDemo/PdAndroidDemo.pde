import com.pdplusplus.*;

/*
Demo
*/

//declare Pd Android to run in Android mode
 PdAndroid pd;
 MyMusic music;
 int numOfTouches = 0;
 int max = 15;
 boolean []id;
 
 void setup() {
  fullScreen();
  noStroke();
  fill(0); 
  textFont(createFont("SansSerif", 24 * displayDensity));
  textAlign(CENTER, CENTER);
  orientation(PORTRAIT);
  
  id = new boolean[max];
  
  for(int i = 0; i < max; i++)
  {
     id[i] = false; 
  }
  
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
  background(255);
  music.setNumOfTouches(touches.length);
   
  for (int i = 0; i < touches.length; i++) {
    float d = (100 + 100 * touches[i].area) * displayDensity;
    fill(0, 255 * touches[i].pressure);
    ellipse(touches[i].x, touches[i].y, d, d);
    fill(255, 0, 0);
    text(touches[i].id, touches[i].x + d/2, touches[i].y - d/2);
  
    music.setFundamental( map(touches[0].y, 0, height, 500, 200) );
  } 
  
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
  Demo:  We will make a turn on a new oscillator for every touch.
  */  

class MyMusic extends PdAlgorithm {
   
    int max = 5;
    Synth [] synths;
    double fundamental = 200;
    
   MyMusic() {
     
     synths = new Synth[max];
      
     for(int i = 0; i < max; i++)
      {
         synths[i] = new Synth(); 
      }
   }
   
   void runAlgorithm(double in1, double in2) {
     
     int n = getNumOfTouches();
     double out, out1, out2, out3, out4 = 0;
    
     out = synths[0].perform((getFundamental()), 1, n>0?true:false);
     out1 = synths[1].perform((getFundamental()*2), 1, n>1?true:false);
     out2 = synths[2].perform((getFundamental()*3), 1, n>2?true:false);
     out3 = synths[3].perform((getFundamental()*4), 1, n>3?true:false);
     out4 = synths[4].perform((getFundamental()*5), 1, n>4?true:false);
     
     outputL = outputR = (out + out1 + out2 + out3 + out4)/max;

   }
  
  synchronized void setFundamental(double f) {
     fundamental = f; 
  }
  
  synchronized double getFundamental() {
     return fundamental; 
  }
  
   synchronized void setNumOfTouches(int i) {
     numOfTouches = i;
   }
   
   synchronized int getNumOfTouches() {
     return numOfTouches;
   }
   
  //Free any Pd4P3 objects you create here.
   void free() {
     for(int i = 0; i < synths.length; i++)
     {
        synths[i].free();
     }
     
   }
  
   
 }
