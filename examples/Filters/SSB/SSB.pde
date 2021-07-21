import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freqShift = 0;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   music.setSSB();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  background(255);
  freqShift = map(mouseX, 0, width, -200, 200);
  music.setFreqShift(freqShift);
  fill(50);
  text(str(freqShift), 10, 10);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is an example of frequency shifting using single sideband modulation (SSB).
   
 */
 class MyMusic extends PdAlgorithm {

   BiQuad biquad1 = new BiQuad();
   BiQuad biquad2 = new BiQuad();
   BiQuad biquad3 = new BiQuad();
   BiQuad biquad4 = new BiQuad();
   Phasor phasor = new Phasor();
   Oscillator osc = new Oscillator();
   Cosine cosLeft = new Cosine();
   Cosine cosRight = new Cosine();
   SoundFiler wav = new SoundFiler();
   float freqShift = 0;
   double[] soundFile;
   String file = "C:\\Users\\***\\Documents\\Pd4P3\\Pd4P3\\examples\\Filters\\SSB\\Bach.wav";
   double fileSize;
   int counter = 0;
   double ch1 = 0;
   double ch2 = 0;
   
   //Single Sideband Modulation, or frequency shifting
   void runAlgorithm(double in1, double in2) {
   
     //loop an audio file
      if(counter != fileSize)
      {
          ch1 = soundFile[counter++];
          ch2 = soundFile[counter++];
          if(counter == fileSize) counter = 0;
      }
    
     /*
       We run our allpass filters (see below) in series, this is also 
       called a Hilbert transform
     */
     double input = (ch1 + ch2) * .5; //convert to mono
     double hilbertRight = biquad2.perform( biquad1.perform(input) );
     double hilbertLeft = biquad4.perform(biquad3.perform(input));
     
     /*
       This part is also called complex modulation, similar to ring modulation
       but only shifts one set of frequencies instead of a positive and negative
     */
     double phase =  phasor.perform( getFreqShift() );
     double cos =  cosLeft.perform(phase);
     double sine = cosRight.perform( phase + -.25);
     
     double out = (hilbertLeft * cos) - (hilbertRight * sine) ;
     outputL = outputR = out; 
     
   }
  
  public void setSSB() {
    /*
      According to H09.ssb.modulation.pd this creates a pair of allpass
      filters that shift the input by 90 degrees, making them suitable
      real and imaginary pairs.
    */
     biquad1.setCoefficients(1.94632, -0.94657, 0.94657, -1.94632, 1);
     biquad2.setCoefficients(0.83774, -0.06338, 0.06338, -0.83774, 1);
     biquad3.setCoefficients(-0.02569, 0.260502, -0.260502, 0.02569, 1);
     biquad4.setCoefficients(1.8685, -0.870686, 0.870686, -1.8685, 1);
     
     //We're just going set our sound file here
     fileSize = wav.read(file);
     soundFile = wav.getArray();
  }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreqShift(float f1) {
     freqShift = f1;
   }
   
   synchronized float getFreqShift() {
     return freqShift;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     BiQuad.free(biquad1);
     BiQuad.free(biquad2);
     BiQuad.free(biquad3);
     BiQuad.free(biquad4);
     Phasor.free(phasor);
     Oscillator.free(osc);
     Cosine.free(cosLeft);
     Cosine.free(cosRight);
     SoundFiler.free(wav);
     
   }
   
 }
