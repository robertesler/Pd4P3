import com.pdplusplus.*;

/*
    Time compression and expansion with loops
    based on Miller Puckette's "b14.sampler.rockafella.pd" example
    in Pure Data.
    
   This sketch shows you a slick way to get some fun audio table
   reading effects.  
   The x/y change the transposition and precession read point
   When the mouse is pressed you can set the chunk size and 
   loop length.
   'R' or 'r' will reset to the starting params.
*/
 
 Pd pd;
 MyMusic music;
 
 boolean paramSwitch = false;
 float bgc = 255;

 void setup() {
   size(640, 360);
   background(bgc);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   music.loadAudioFile("C:\\Users\\&&&\\Desktop\\voice.wav");
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   
   if(!paramSwitch)
   {  
      background(bgc);
      float t = map(mouseX, 0, width, -80, 80);
      music.setTransposition(t);
      float p = map(mouseY, 0, height, 0, 100);
      music.setPrecession(p);
      fill(0);
      String s = "transp: " + str(t) + " prec: " + str(p);
      text(s, mouseX, mouseY);
   }
   
   if(paramSwitch)
   {
      background(bgc-100);
      float c = map(mouseY, 0, height, 100, 10);
      music.setChunkSize(c);
      float l = map(mouseX, 0, width, 100, 1000);
      music.setLoopLength(l);
      fill(0);
      String s = "chunk: " + str(c) + " loop: " + str(l);
      text(s, mouseX, mouseY);
   }
  
  line(0, mouseY, width, mouseY);
  line(mouseX, 0, mouseX, height);
  
  if(key == 'r' || key == 'R')
  {
   music.reset(); 
  }
  
 }
 
 void mousePressed() {
   paramSwitch = true;
 }
 
 void mouseReleased() {
   paramSwitch = false; 
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This class will set the chunk size, precession point, loop length and 
   transposition of buffer for various time compression and pitch shift 
   effects.
 */
 class MyMusic extends PdAlgorithm {
   
   TabRead4 tabread1 = new TabRead4();
   TabRead4 tabread2 = new TabRead4();
   SampleHold samphold1 = new SampleHold();
   SampleHold samphold2 = new SampleHold();
   Cosine cos1 = new Cosine();
   Cosine cos2 = new Cosine();
   Phasor phasor1 = new Phasor();
   Phasor phasor2 = new Phasor();
   SoundFiler soundfiler = new SoundFiler();
   HighPass hip = new HighPass();
   Wrap wrap = new Wrap(); //does not need to be freed.
   double[] loop;
   int fileSize;
   float transposition = -20;
   float chunkSize = 25;
   float precession = 60;
   float loopLength = 900;
   float readPoint = 0;
   float phase1 = 0;
   float phase2 = 0;
   
   /*
   Read from the same buffer 1/2 a phase apart for a time compression effect
   or time expansion.  
   */
   void runAlgorithm(double in1, double in2) {
     
     //We have our first read point and phase here
      readPoint = (float)phasor1.perform( getPrecession()/getLoopLength() ) * getLoopLength();
      phase1 = (float)phasor2.perform(getTransposition());
      phase2 = wrap.perform(phase1 + .5);
      double first = samphold1.perform(getChunkSize(), phase1)* phase1;
      first += readPoint;
      first = (first * this.getSampleRate()) + 1;
      double table1 = tabread1.perform(first) * cos1.perform((phase1 - .5) *.5);
      //Our second read point and second phase
      double second = samphold2.perform(getChunkSize(), phase2)* phase2;
      second += readPoint;
      second = (second * this.getSampleRate()) + 1;
      double table2 = tabread2.perform(second) * cos2.perform((phase2 - .5) *.5);
      
      hip.setCutoff(5);//Reduce DC
      outputL = outputR = hip.perform(table1 + table2); //add each phase together
     
   }
  
  //open a short uncompressed audio file
  public void loadAudioFile(String f) {
     fileSize = (int)soundfiler.read(f); 
     loop = new double[fileSize+4];
     loop = soundfiler.getArray();
     tabread1.setTable(loop);
     tabread2.setTable(loop);
     setChunkSize(25);
     setPrecession(60);
     setLoopLength(900);
     setTransposition(-20);
  }
  
  synchronized void reset() {
     setChunkSize(25);
     setPrecession(60);
     setLoopLength(900);
     setTransposition(-20);
  }
  
  synchronized void setChunkSize(float cs) {
    chunkSize = cs/1000;//msec
  }
  
  synchronized float getChunkSize() {
    return chunkSize;
  }
  
  synchronized void setPrecession(float p) {
    precession = p/100;//in %
  }
  
  synchronized float getPrecession() {
     return precession; 
  }
   //(2^t/120 - p)/c
   synchronized void setTransposition(float f1) {
     transposition = (pow(2, f1/120)-getPrecession())/getChunkSize();
    
   }
   
   synchronized float getTransposition() {
     return transposition;
   }
   
   synchronized void setLoopLength(float l) {
      loopLength = l/1000;//msec 
   }
   
   synchronized float getLoopLength() {
       return loopLength;//also in msec
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     TabRead4.free(tabread1);
     TabRead4.free(tabread2);
     SampleHold.free(samphold1);
     SampleHold.free(samphold2);
     Cosine.free(cos1);
     Cosine.free(cos2);
     Phasor.free(phasor1);
     Phasor.free(phasor2);
     SoundFiler.free(soundfiler);
     HighPass.free(hip);
   }
   
 }
