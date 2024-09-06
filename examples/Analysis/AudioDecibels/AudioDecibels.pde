import com.pdplusplus.*;


/*
This example reads an audio file and calculates the linear output (0 to 1) to decibels
using the Pd4P3 class Envelope.  
Use the mouse the change the linear volume (0-1) via the x-axis.
*/


//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float vol = 1;
 double dB = 0;
 

 void setup() {
   size(640, 360);
   background(255);
   String file = this.dataPath("Bach.wav");
   music = new MyMusic();
   music.readFile(file);
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
   dB = music.getDecibels(); 
   String v = str(vol);
   String d = str((int)dB);
   String s = "Volume: " + v + " | dB: " + d;
   fill(50);
   text(s, 10, 10, 250, 100); 
   vol = map(mouseX, 0, width, 0, 1);
   music.setVolume(vol);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 
