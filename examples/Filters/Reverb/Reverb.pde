import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float modulationIndex = 400;
 float carrier = 100;
 float mix = 0;
 boolean circleDraw = false;

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);

   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
   
   carrier = map(mouseX, 0, width, 400.0, 1200.0);
   music.setCarrierFreq(carrier);
   
   mix = map(mouseX, 0, width, .1, 2);
   music.setMix(mix);
   
   modulationIndex = map(mouseY, 0, height, 10.0, 350.0);
   music.setModIndex(modulationIndex);

   if(circleDraw)
   {
     background(255);
       color c = color(map(modulationIndex, 10, 350, 10, 255), map(carrier, 400, 1200, 10, 255), map(mouseX, 0, width, 10, 255));  // Define color 'c'
      fill(c);  // Use color variable 'c' as fill color
      noStroke();  // Don't draw a stroke around shapes
      circle(mouseX, mouseY, 55); 
      circleDraw = false;
      music.setBang(circleDraw);
   }
 }
 
 void mouseClicked() {
   music.setBang(true);
   circleDraw = true;
 }
 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped");
    super.dispose();
}
 
 
 class MyMusic extends PdAlgorithm {
   
   //create new objects like this
    Oscillator osc1 = new Oscillator();
    Oscillator osc2 = new Oscillator();
    Oscillator osc3 = new Oscillator();
    Line line = new Line();
    Rev3 rev3 = new Rev3();
    float modFreq = 300;
    float modIndex = 100;
    float carrierFreq = 200;
    float amplitude = .9;
    float mix = .7;
    boolean bang = false;
    float attack = 50;
    float release = 750;
    double env = 0;
     
     MyMusic() {
        rev3.setAll(94, 96, 5000, 88); 
     }
     
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
 
     //From the Classic FM sketch 
     double fm = osc1.perform( carrierFreq + ( osc2.perform(carrierFreq * 2.5)* getModIndex()) ) * (amplitude * env );
     double[] wet = rev3.perform(fm, fm);//multiply by a mix factor    
     outputL = fm + (wet[0] + wet[2]) * getMix();//wet plus dry
     outputR = fm + (wet[1] + wet[3]) * getMix();
     //println("wet: " + wet[0] + wet[2]);
     /*
     This is how to do an envelope, just attack and release for now, using Line()
     */
     if(getBang())
     {
       env = line.perform(1, attack);  
     }
     else
     {
       env = line.perform(0, release); 
     }
     
     if(env == 1)
     {
       bang = false;
     }
     
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setModIndex(float f1) {
     modIndex = f1;
   }
   
   synchronized float getModIndex() {
      
     return modIndex;
   }
   
    synchronized void setCarrierFreq(float f1) {
     carrierFreq = f1;
   }
   
   synchronized float getCarrierFreq() {
    
     return carrierFreq;
   }
   
   synchronized void setBang(boolean b) {
     bang = b;
   }
   
  synchronized boolean getBang() { 
     return bang;
   }
   
   synchronized void setMix(float m) {
     mix = m;
   }
   
   synchronized float getMix() {
      return mix;  
   }
   
   void free() {
     Oscillator.free(osc1);
     Oscillator.free(osc2);
     Oscillator.free(osc3);
     Line.free(line);
     rev3.free();
   }
   
 }
