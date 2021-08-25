import com.pdplusplus.*;

/*
This is an example of how to employ panning and volume curves.  
I only used a resonant tone so I could feel the panning working
as well as hear it.  Sometimes it is good to verify before
publishing.  
*/

 Pd pd;
 MyMusic music;
 
 float dummyFloat = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  float p = map(mouseX, 0, width, 0, 1);
  music.setPan(p);
  float a = map(mouseY, 0, height, 100, 0);
  music.setVolume(a);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 
 /*
   We will employ a basic pan algorithm and smooth the volume using Line
 */
 class MyMusic extends PdAlgorithm {
   
   Noise noise = new Noise();
   Oscillator osc = new Oscillator();
   LowPass lop = new LowPass();
   Line left = new Line();
   Line right = new Line();
   Line volume = new Line();
   Cosine cosL = new Cosine();
   Cosine cosR = new Cosine();
   float pan = 0;
   float amp = 70;//in dB
   
   /*
   Here we use two signal level Cosine functions to move our
   left and right channels 90 degrees out of phase from each other
   creating a standard pan effect.  At center, the drop should be -3dB.  
   Our volume is also controlled using a ramp, or Line, to avoid clicks
   in our audio.  In this example our audio uses a parabolic curve (x^2)
   you can also use this.dbtorms() if you want a true RMS curve.  
   */
   void runAlgorithm(double in1, double in2) {
     
     double l = cosL.perform( left.perform( getPan(), 50) );
     double r = cosR.perform( right.perform( (getPan()) - .25, 50) ) ;
     lop.setCutoff(5000);
     double n = osc.perform( lop.perform((noise.perform() + 100) * 4 ) );//resonant oscillator, easier to feel in the speakers.
     double a = volume.perform(  getVolume()*getVolume() , 50 );
     outputL = n * l * a;
     outputR = n * r * a;
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setPan(float f1) {
     pan = f1;
   }
   
   //divide by four to get a quarter phase apart, aka 90 degrees
   synchronized float getPan() {
     return pan/4;
   }
   
   synchronized void setVolume(float a) {
       amp = a;
   }
   
   //our volume is set in dB, you could also just use linear 0-1 too.
   synchronized float getVolume() {
      return amp/100; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     Oscillator.free(osc);
     LowPass.free(lop);
     Line.free(left);
     Line.free(right);
     Line.free(volume);
     Cosine.free(cosL);
     Cosine.free(cosR);
     
   }
   
 }
