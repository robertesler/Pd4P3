import com.pdplusplus.*;

/*
This is a classic phaser example
X = frequency
Y = phaser rate

*/
 Pd pd;
 MyMusic music;
 
 double freq = 200;
 double rate = .3;

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   freq = map(mouseX, 0, width, 150, 400);
   rate = map(mouseY, height, 0, .2, 5);
   music.setFreq(freq);
   music.setRate(rate);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 
 class MyMusic extends PdAlgorithm {
   
   Chord [] chord; 
   RealZeroReverse [] rzero_rev;
   RealPole [] rpole;
   HighPass hip = new HighPass();
   Phasor phasor = new Phasor();
   double freq = 0;
   double rate = .3;
   int max = 4;
   
   MyMusic() {
    
    chord = new Chord[max];
    rzero_rev = new RealZeroReverse[max];
    rpole = new RealPole[max];
    hip.setCutoff(5);
    
    for(int i = 0; i < max; i++)
    {
        chord[i] = new Chord();
        rzero_rev[i] = new RealZeroReverse();
        rpole[i] = new RealPole();
    }
     
   }
   
   /*
   Here we use a 4 stage allpass and add back into our chord.
   The filtered copy will cancel out frequencies from our sum
   and we get a classic phaser effect.
   */
   void runAlgorithm(double in1, double in2) {
     
     double c1 = chord[0].perform(getFreq());
     double c2= chord[1].perform(getFreq() * 1.333);
     double c3 = chord[2].perform(getFreq() * 1.5);
     double c4 = chord[3].perform(getFreq() * 2);
     double sum = hip.perform( (c1 + c2 + c3 + c4) ) * .2;
     double coef = getCoef( phasor.perform(getRate()) );
     double rzero1 = rzero_rev[0].perform(sum, coef);
     double rpole1 = rpole[0].perform(rzero1, coef);
     double rzero2 = rzero_rev[1].perform(rpole1, coef);
     double rpole2 = rpole[1].perform(rzero2, coef);
     double rzero3 = rzero_rev[2].perform(rpole2, coef);
     double rpole3 = rpole[2].perform(rzero3, coef);
     double rzero4 = rzero_rev[3].perform(rpole3, coef);
     double rpole4 = rpole[3].perform(rzero4, coef);
     outputL = outputR = sum + rpole4;; 
     
   }
   
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(double f1) {
     freq = f1;
   }
   
   synchronized double getFreq() {
     return freq;
   }
   
   synchronized void setRate(double r) {
     rate = r;
   }
   
   synchronized double getRate() {
    return rate;
   }
   
   //calculate our allpass coefficients
    synchronized double getCoef(double input) {
      double tri = abs((float)input - .5f);//phasor input converted to triangle wave
      double ph = 1 - .03 - (0.6 * tri * tri); //set range
     return ph;
   }
   //Free all objects created from Pd4P3 lib
   void free() {
     HighPass.free(hip);
     Phasor.free(phasor);
     
     for(int i = 0; i < max; i++)
     {
        chord[i].free();
        RealZeroReverse.free(rzero_rev[i]);
        RealPole.free(rpole[i]);
     }
     
   }
   
 }
