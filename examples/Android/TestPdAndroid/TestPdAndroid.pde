import com.pdplusplus.*;
import android.util.Log;

/*
This is an example of how to use Pd4P3 in Android mode.
The basic idea is the same, but the initialization is
a bit different.  For example, in Android the audio 
thread needs to be started after you start calculating 
audio.  

You also need to ask for microphone permissions before
starting the audio loop.
*/

//declare Pd Android to run in Android mode
 PdAndroid pd;
 MyMusic music;
 float freq = 0; 
 float modulationIndex = 400;
 float carrier = 100;
 float delayTime = 500;
 float delayFeedback = .3;
 boolean circleDraw = false;
 
 void setup() {
  fullScreen();
  noStroke();
  fill(0); 
  orientation(PORTRAIT);
  
   music = new MyMusic();
   pd = new PdAndroid(music);
   
   //Log.d("PD ANDROID: ", "pd is created");
  
  //You must ask for microphone permissions before starting
   if(isRecordPermissionGranted())
    {
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
 
 //This is still in testing mode.  
 void backPressed() {
   exit();
 }

 void draw() {
   
   carrier = map(mouseX, 0, width, 400.0, 1200.0);
   music.setCarrierFreq(carrier);
   
   delayTime = map(mouseX, 0, width, 50.0, 300.0);
   music.setTime(delayTime);

   modulationIndex = map(mouseY, 0, height, 10.0, 350.0);
   music.setModIndex(modulationIndex);
   
   delayFeedback = map(mouseY, 0, height, .1, .9);
   music.setFeedback(delayFeedback);

   if(circleDraw)
   {
     background(255);
     color c = 0;
     for(int i = 0; i < touches.length; i++)
     {
        c= color(map(modulationIndex, 10, 350, 10, 255), 
                 map(carrier, 400, 1200, 10, 255), map(touches[i].pressure, 0, width, 10, 255));  // Define color 'c'
     }
      fill(c);  // Use color variable 'c' as fill color
      noStroke();  // Don't draw a stroke around shapes
      for(int i = 0; i < touches.length; i++)
        circle(touches[i].x, touches[i].y, 100); 
      circleDraw = false;
      music.setBang(circleDraw);
   }
  
 }
 
  void touchStarted() {
   music.setBang(true);
   circleDraw = true;
 }
 
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
   On Android this is all basically the same as Pd4P3 on Mac/Win/Linux.
   
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   //create new objects like this
    Oscillator osc1 = new Oscillator();
    Oscillator osc2 = new Oscillator();
    Oscillator osc3 = new Oscillator();
    Line line = new Line();
    VariableDelay vd = new VariableDelay();
    float modFreq = 300;
    float modIndex = 100;
    float carrierFreq = 200;
    float amplitude = 1;
    float delayTime = 500;
    float pDelayTime = 500;//for lerp(), previous value
    float delayFeedback = .3;
    float pDelayFeedback = .3;//for lerp(), previous value
    boolean bang = false;
    float attack = 50;
    float release = 750;
    double env = 0;
    double t = 0; //smoothing
    double out = 0;
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
     //Classic FM 
     double fm = osc1.perform( carrierFreq + ( osc2.perform(carrierFreq * 2.5)* getModIndex()) ) * (amplitude * env );
     t = t - .0001 * (t - getTime()); //smooth our delayTime to get rid of crackles
     //Our delayed output with doppler
     vd.delayWrite(out * getFeedback());//feedback our output with an amplitude multiplier less than 1. 
     out = vd.perform( getTime() *  t ) + (double)fm; //add fm to our delay line  
    
    
     outputL = outputR = out;

     /*
     This is how to do an envelope using Line()
     */
     if(getBang())
     {
     env = line.perform(1, attack);  
     }
     else
     {
      env = line.perform(0, release); 
     }
     
     if(env == 1)
     {
       bang = false;
     }
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setModIndex(float f1) {
     modIndex = f1;
   }
   
   synchronized float getModIndex() {
      
     return modIndex;
   }
   
    synchronized void setCarrierFreq(float f1) {
     carrierFreq = f1;
   }
   
   synchronized float getCarrierFreq() {
    
     return carrierFreq;
   }
   
   synchronized void setTime(float f1) {
     delayTime = f1;
   }
   
   synchronized float getTime() {
     return delayTime;
   }
   
   synchronized void setFeedback(float f1) {
     delayFeedback = f1;
   }
   
   synchronized float getFeedback() {
     return delayFeedback;
   }
   
   synchronized void setBang(boolean b) {
     bang = b;
   }
   
  synchronized boolean getBang() { 
     return bang;
   }
   
   void free() {
     Oscillator.free(osc1);
     Oscillator.free(osc2);
     Oscillator.free(osc3);
     Line.free(line);
     VariableDelay.free(vd);
   }
   
 }
