import com.pdplusplus.*;

/*
This sketch will create a simple "bing" sound when clicked on
and change the pitch and color of the circles based on 
the x-axis.

Look at the code in the Bing class for how to make the sound.

In general this is another type of synthesis model but without
a name.  Perhaps it's the Esler Bing Synthesis Model.
*/
 Pd pd;
 MyMusic music;
 
 float pitch = 72;
 float alpha = 255;

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   background(255);
   pitch = map(mouseX, 0, width, 64, 84);
     color c = color(map(pitch, 10, 350, 10, 255), map(mouseY, 0, height, 10, 255), 
                     map(mouseX, 0, width, 10, 255), alpha);  // Define color 'c'
      fill(c);  // Use color variable 'c' as fill color
      noStroke();  // Don't draw a stroke around shapes
      circle(mouseX, mouseY, 55); 
      alpha -= 2;
      if(alpha == 0) alpha = 0;
 }
 
 void mousePressed() {
  music.setBang(); 
  music.setPitch(pitch);
  alpha = 255;
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is a model of the classic Nintendo Wii "Bing" used in their
   UI back in 2006.
 */
 class MyMusic extends PdAlgorithm {
   
   Bing bing = new Bing();
   Reverb rev = new Reverb();
   float pitch = 72;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double b = bing.perform(getPitch());
     double r = rev.perform( b );
     outputL = outputR = b * .5 + r * .3; 
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setPitch(float f1) {
     pitch = f1;
   }
   
   synchronized float getPitch() {
     return pitch;
   }
   
   synchronized void setBang() {
     bing.setBang(true);
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     bing.free();
     rev.free();
   }
   
 }
