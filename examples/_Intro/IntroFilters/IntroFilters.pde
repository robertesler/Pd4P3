import com.pdplusplus.*;

/*
Filters are the next topic.  In Pd++ there are several standard filters:
LowPass
HighPass
BandPass
AND
BiQuad - a two pole, two zero filter.  One way to make a custom filter.
And raw filters. We won't get into these either but those include:
ComplexPole
ComplexZero
ComplexZeroReverse
RealPole
RealZero
RealZeroReverse
*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  float freq = map(mouseX, 0, width, 100, 500);
  music.setFreq(freq);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is where you should put all of your music/audio behavior and DSP
   You could also put this class in a new tab
 */
 class MyMusic extends PdAlgorithm {
   
   float freq = 0;
   Noise noise = new Noise();
   LowPass lop = new LowPass();
   HighPass hip = new HighPass();
   BandPass bp = new BandPass();
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
    
    //Low Pass filter, set the cutoff first, then apply the filter
    lop.setCutoff(getFreq());
    outputL = outputR =lop.perform( noise.perform() );
    
    
    //High Pass
    /*
    hip.setCutoff(getFreq() * 10);
    outputL = outputR = hip.perform( noise.perform() );
    */
    
    //Band Pass, we set the center frequency, and bandwidth or Q
    /*
    bp.setCenterFrequency(getFreq() * 2);
    bp.setQ(.5);
    outputL = outputR = bp.perform( noise.perform() );
    */
    
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f) {
     freq = f;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     LowPass.free(lop);
     HighPass.free(hip);
     BandPass.free(bp);
   }
   
 }
