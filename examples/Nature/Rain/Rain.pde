import com.pdplusplus.*;

/*
This is an example of rain drops on a glass surface.
The example is inspired by Andy Farnell's "Designing Sound"
book. 
Set the rain and rain volume for different intensities.

*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float rain = .1;
 float rainVol = 3;
 float bpCf = 1400;
 float bpQ = 2;
 float bpRainVol = 2.8;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  rain = map(mouseX, 0, width, .001, .1);
  bpCf = map(mouseX, 0, width, 1400, 900);
  bpQ = map(mouseX, 0, width, 2, 3);
  rainVol = map(mouseY, height, 0, 2, 4);
  bpRainVol = map(mouseY, height, 0, 1, 3);
  music.setRain(rain, rainVol, bpCf, bpQ, bpRainVol);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   Our Rain Generator
 */
 class MyMusic extends PdAlgorithm {
   
   float dummy = 0;
   Noise noise = new Noise();
   BandPass bp = new BandPass();
   HighPass hip = new HighPass();
   LowPass lop = new LowPass();
   Delay del = new Delay();
   Drop drop = new Drop();
   GlassWindow window = new GlassWindow();
   Reverb reverb = new Reverb();
   double delread = 0;
   double rain = 0.1;
   double rainVol = 3;
   double bpCf = 1400;
   double bpQ = 2;
   double bpRainVol = 2.8;
   
   public MyMusic() {
    del.setDelayTime(300); 
    hip.setCutoff(9000);
    lop.setCutoff(500);
    bp.setCenterFrequency(bpCf);
    bp.setQ(bpQ);
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     outputL = outputR = 0; 
     double dropInput = (del.perform(delread) * 24) + 6;
     double n = noise.perform();
     double farFieldRain = bp.perform(n) * (bpRainVol * .01);
     double x = drop.perform(n, dropInput, rain, rainVol);
     double win = hip.perform(x) * 20; 
     delread = window.perform(win);
     double combo = delread + farFieldRain;
     double r = reverb.perform(combo);
     outputR = lop.perform(delread) + combo + r *.4;
     outputL = outputR;
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setRain(float r, float rv, float bpf, float q, float ffrv) {
     rain = r;
     rainVol = rv;
     bpCf = bpf;
     bpQ = q;
     bpRainVol = ffrv;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     HighPass.free(hip);
     LowPass.free(lop);
     BandPass.free(bp);
     Delay.free(del);
     drop.free();
     window.free();
     
   }
   
 }
