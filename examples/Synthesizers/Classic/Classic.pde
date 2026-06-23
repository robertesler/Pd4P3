import com.pdplusplus.*;

/*
Using our oversampling example, we can make a classic 
synthesizer using a phasor and the Bob filter, which is
a Moog-style resonant filter. 

X-axis is the pitch, Y-axis is the filter cutoff.

This is based on Pure Data's example J08.classicsynth.pd
*/

//declare Pd and create new class that inherits PdAlgorithm

 Pd pd;
 MyMusic music;
 
float [] regions = new float[9];
float [] scale = {48, 50, 51, 53, 55, 56, 58, 60};

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   //start the Pd engine thread
   pd.start();
   
   regions[0] = 0;//redundant assignment
   
   //set 8 regions across the canvas
   for(int i = 1; i < regions.length; i++)
     regions[i] = regions[i-1] + width/8;
 }
 
 void draw() {
    background(0);
    for(int i = 0; i < regions.length-1; i++)
    {
      
      if(mouseX > regions[i] && mouseX < regions[i+1])
      {
        
         music.setFreq(scale[i]);
         fill(200, 200, 200);
         text("MIDI: " + scale[i], mouseX+40, mouseY+10);
         fill(150);
         rect(regions[i], 0, width/8, height);
         
      }
    }

   
    float s = map(mouseY, height, 0, 3500, 800);
    music.setFreqScaler(s);
    fill(255);
   
    textSize(32);
    text("Click to play", 50, 50);
    textSize(12);
    
   
 }
 
 void mousePressed() {
    music.setBang(true);
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
   println("Pd4P3 audio engine stopped.");
   super.dispose();
}
 
 /*
  Our synthesizer, we use two phasors each scaled to create a squarish-type waveform.
  Then we use a Moog-style resonant filter to get our throaty buzz.  
  
  Additionally we use the oversampling method from Oversampling.pde to anti-alias our
  waveforms.  
 */
 class MyMusic extends PdAlgorithm {
   
   double freq = 932;
   Phasor phasor = new Phasor();
   Phasor phasor2 = new Phasor();
   BobFilter bob = new BobFilter();
   Line line = new Line();
   int upsample = 16;
   Butterworth butterworth = new Butterworth(15000, this.getSampleRate()*upsample*.5, 0, upsample);
   double env = 0;
   double cutoff = 500;
   double cScaler = 2000; //our cutoff scale factor
   boolean bang = false;
   boolean decay = false;
   
   public MyMusic()
   {
      bob.setResonance(3); 
   }

   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     
       double [] buffer = new double[upsample];
       for(int i = 0; i < upsample; i++)
       {
           double p1 = phasor.perform( this.getFreq() / upsample );
           double p2 = phasor2.perform( ((this.getFreq() + .5) / upsample)  );
           double sig = (p1 + this.wrap(p1 - .5) * -.5) + (p2 + (this.wrap(p2 - .5) * .5));
           buffer[i] = butterworth.perform(sig); 
       }
       
       bob.setCutoffFrequency(cutoff);
       outputL = outputR = bob.perform(buffer[0]) * (env*env);
        
       if(getBang())
       {
          env = line.perform(1, 50); 
          double rf =  env + .2;
          cutoff = (rf*rf) * getFreqScaler();
       }
       else
       {
          env = line.perform(0, 850); 
          double rf =  env + .2;
          cutoff = (rf*rf) * getFreqScaler();
       }
       
       if(env == 1)
         this.setBang(false);   
          
   }
   
    //Returns only the decimal portion of a number
   private double wrap(double in) {
     double out = 0;
     int k;
     double f = in;
     f = ((f > Integer.MAX_VALUE || f < Integer.MIN_VALUE) ? 0. : f);
     k = (int)f;
     if( k <= f)
       out = f-k;
     else
       out = f - (k-1);
       
     return out;
    }
   
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(double f) {
     freq = this.mtof(f);
   }
   
   synchronized double getFreq() {
     return freq;
   }
   
   synchronized void setFreqScaler(double fscale) {
      cScaler = fscale; 
   }
   
   synchronized double getFreqScaler() {
      return cScaler; 
   }
   
   synchronized void setBang(boolean b) {
      bang = b; 
   }
   
   synchronized boolean getBang() {
     return bang;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Phasor.free(phasor);
     Phasor.free(phasor2);
     BobFilter.free(bob);
     Line.free(line);
     butterworth.free();
   }
   
 }
