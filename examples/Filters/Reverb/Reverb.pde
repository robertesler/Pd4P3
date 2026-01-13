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
   
   carrier = map(mouseX, 0, width, 200.0, 800.0);
   music.setFreq(carrier);
   
   mix = map(mouseY, height, 0, .5, 1);
   music.setMix(mix);

   if(circleDraw)
   {
     background(255);
     color c = color(map(modulationIndex, 5, 50, 10, 255), 
                       map(carrier, 200, 800, 10, 255),
                       map(mouseX, 0, width, 10, 255));  // Define color 'c'
     fill(c);  // Use color variable 'c' as fill color
     noStroke();  // Don't draw a stroke around shapes
     circle(mouseX, mouseY, 55); 
     circleDraw = false;
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
   
    Oscillator osc1 = new Oscillator();
    HighPass hip = new HighPass();
    Cosine cos = new Cosine();
    Line line = new Line();
    Rev3 rev3 = new Rev3();
    float freq = 200;
    float amplitude = .1;
    float mix = .7;
    boolean bang = false;
    float attack = 1000;
    double env = 0;
    long counter = 0;
     
     /*
     Set our four variables:
     1) Output level 0-100
     2) Liveness 0-100
     3) Crossover in Hz
     4) Damping 0-100
     */
     
     public MyMusic() 
     {
        rev3.setAll(100, 92, 3000, 40); 
        hip.setCutoff(5);
     }
     
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
  
     double sig = osc1.perform( getFreq() );
     double sigSq = sig * sig;
     double sigCube = sigSq * sig;
     double sigQuad = sigSq * sigSq;
     double sum = sig + sigSq + sigCube + sigQuad;
     double synth = hip.perform(sum * amplitude * env);
     double[] wet = rev3.perform(synth, synth);  
     outputL = synth * (1-getMix()) + (wet[0] + wet[2]) * getMix();//wet plus dry
     outputR = synth * (1-getMix()) + (wet[1] + wet[3]) * getMix();
     
     /*
     This is another way to create an envelope
     It creates a sinusoidal shape using cosine
     */
     if(getBang())
     {
       env = cos.perform( (line.perform(1, attack) * .5) - .25);  
       counter++;
     }
   
     if(counter == (int)(line.getSampleRate() * (attack/1000)))
     {
       bang = false;
       counter = 0;
       line.perform(0, 0); 
     }
     
   }
  
  //We use synchronized to communicate with the audio thread
 
    synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
    
     return freq;
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
     HighPass.free(hip);
     Cosine.free(cos);
     Line.free(line);
     rev3.free();
   }
   
 }
