import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float bpm = 120;
 int shift = 0;
 boolean drawShape = false;
 int shapeInc = 0;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
  bpm = map(mouseX, 0, width, 120, 800);
  shift = (int)map(mouseY, 0, height, 0, 11);
  music.setBPM(bpm);
  music.setShift(shift);
 
  if(music.getShape())
  {
    background(255);
    fill(50);
    text(str(bpm), 10, 10); 
  
    int x = shapeInc;
    int y = (height/12)*shift;
     
    fill(map(mouseX, 0, width, 0, 200), map(mouseY, 0, height, 50, 150), 100);
    rect(x+20, y, 55, 55, 7);
    shapeInc += width/8;
    if(shapeInc > width)
      shapeInc = 0;
    
    music.setShape(false);
  }
 }
 

 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is a basic sequencer example
 */
 class MyMusic extends PdAlgorithm {
   
   VoltageControlFilter vcf = new VoltageControlFilter();
   Phasor phasor = new Phasor();
   Line line = new Line();
   double attack = 40;
   double hold = 20;
   double release = 80;
   int[] notes = {60, 62, 64, 65, 67, 69, 71, 72 };
   int counter = 0;
   int metro = 0;
   int del = 0;
   int shift = 0;
   int freqShift = 0;
   boolean metroOn = true;
   boolean seqBang = false;
   boolean shape = false;
    double freq = 0;
   double bpm = 120;
   double amplitude = .95;
   double env = 0;
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
  
     //set up our metronome
     double metroTime = bpmToMilliseconds(getBPM());
     double metroSamples = (this.getSampleRate() * (metroTime/1000)) + .5f;
     double delSamples = (this.getSampleRate() * (hold/1000)) + .5f;
     
     if(metro == (int)metroSamples && metroOn)
     {
       metro = 0;//reset metro
       del = 0;//reset our hold/del
       counter++;
       if(counter == notes.length) counter = 0;//reset our seq counter
       seqBang = true;//start our envelope generator
       freqShift = getShift(); //get our freq shift
       setShape(true);
     }
     metro++;
     
     if(metro > (int)metroSamples)
       metro = 0;
       
     freq = this.mtof(notes[counter] + freqShift);
     
     //let's make our synth here, filtered square wave (8-bit style)
     double ph = phasor.perform(freq) - .5;
     if(ph > 0)
        ph = 1;
      else
        ph = 0;
     double[] filter = vcf.perform(ph, freq);
     //we'll use the band pass output of the vcf e.g. filter[0]
     double out = filter[0] * (amplitude * env);
     
     //this is our envelope generator (ASR), no decay for now
     if(seqBang)
     {
       env = line.perform(1, attack);
     }
     else if(del++ == delSamples) //our hold or sustain time
     {
      env = line.perform(0, release); 
     }
     
     if(env == 1)
     {
        seqBang = false; 
     }
     
     outputL = outputR = out; 
     
   }
  
  //Convert bpm to milliseconds for our metronome
  private double bpmToMilliseconds(double bpm) {
    double ms = 0;
    ms = 1000 / (bpm/60);
    return ms;
  }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setBPM(float f1) {
     bpm = f1;
   }
   
   synchronized double getBPM() {
     return bpm;
   }
   
   synchronized void setShift(int s) {
      shift = s; 
   }
   
   synchronized int getShift() {
     return shift;
   }
   
   synchronized void setShape(boolean s) {
     shape = s;
   }
   
   synchronized boolean getShape() {
      return shape; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Phasor.free(phasor);
     VoltageControlFilter.free(vcf);
     Line.free(line);
     
   }
   
 }
