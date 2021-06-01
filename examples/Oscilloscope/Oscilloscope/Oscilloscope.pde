import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
 float freq = 400;
 float[] output;
int state = 1;
String banner = "Sine Wave";

 void setup() {
   size(640, 360);
   background(255);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  freq = map(mouseX, 0, width, 20.0, 500.00);
  music.setFreq(freq);
 
 // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
 
 if (keyPressed) {
      if(key == '1')
      {
         state = 1;
         banner = "Sine Wave";
      }
      if(key == '2')
      {
        state = 2;
        banner = "Ramp Wave";
      }
      if(key == '3')
      {
         state = 3;
         banner = "Sawtooth Wave";
      }
      if(key == '4')
      {
        state = 4;
        banner = "Square Wave";
      }
      if(key == '5')
      {
         state = 5;
         banner = "Amplitude Modulation";
      }
      if(key == '6')
      {
        state = 6;
        banner = "Frequency Modulation";
      }
      if(key == '7')
      {
         state = 7;
         banner = "Ring Modulation";
      }
      if(key == '8')
      {
        state = 8;
        banner = "Additive Synthesis";
      }
      if(key == '9')
      {
         state = 9;
         banner = "Microphone";
      }
  }
 
 music.setState(state);
 
 textSize(32);
 text(banner, width/2 - 100, 32);
;
 
   output = music.getOutput();
 
 //Draw the shape based on the output block, once per frame
 //TODO perhaps look at syncing framerate to output.length??
  beginShape();
  for(int i = 0; i < output.length; i++){
    vertex(
      map(i, 0, output.length, width, 0),
      map(output[i], -1, 1, 0, height)
    );
  }
  endShape(); 
 
 }
 
 
 public void dispose() {
    //stop Pd engine
    pd.stop();
    println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   This is where you should put all of your music/audio behavior and DSP
 */
 class MyMusic extends PdAlgorithm {
   
   Oscillator osc1 = new Oscillator();
   Oscillator osc2 = new Oscillator();
   Oscillator osc3 = new Oscillator();
   Phasor phasor = new Phasor();
   Phasor phasor2 = new Phasor();
   Phasor phasor3 = new Phasor();
   float freq = 400;
   int block = 1024; //change this to bigger or small to get better graphing
   float[] writeOutput = new float[block];
   int counter = 0;
   int state = 1;
   
   //You can use this oscilloscope to show how different types of synthesis work
   void runAlgorithm(double in1, double in2) {
     outputL = 0;
     outputR = 0;
     
     switch(getState())
     {
     /****************** Wave Forms ******************/
    case 1:
    /**** Sine Wave (actually cosine wave) ****/
    outputL = outputR = osc1.perform(getFreq());
    break;
    case 2:
    /**** Sawtooth or Ramp wave ****/
    outputL = outputR = phasor.perform(getFreq()) - .5; // -.5 for better graphing
    break;
    case 3:
    /**** Reverse Sawtooth ****/
    outputL = outputR = (phasor2.perform(getFreq()) * -1) + .5 ;// + .5 for better graphing
    break;
    case 4:
    /**** Square Wave ****/
    double out = (phasor3.perform(getFreq()) - .5);
    if(out > 0) out = 1;
    else out = 0;
    outputL = outputR = out - .5;
    break;
  
    /********************* Synthesis ******************/
    case 5:
     /**** Amplitude Modulation ****/
     outputL = outputR = osc1.perform(getFreq()) * (osc2.perform(1) + 1) * .5 ;
    break;
    case 6:
    /**** Classic Frequency Modulation ****/
    outputL = outputR = osc1.perform( getFreq() + ( osc2.perform(getFreq() * 2.5 )* 200) );
    break;
    case 7:
    /**** Ring Modulation ****/
    outputL = outputR = osc1.perform(getFreq()) * osc2.perform(getFreq()*2);
    break;
    case 8:
   /**** Additive Synthesis ****/
    outputL = outputR = osc1.perform(getFreq()) * .5
      + osc2.perform(getFreq()*2) * .333 
      + osc3.perform(getFreq() * 4) * .167;
    break;
    case 9:
      outputL = in1;
      break;
     }
     
    //our ring buffer
     writeOutput[counter++] = (float)outputL;
     
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(float f1) {
     freq = f1;
   }
   
   synchronized float getFreq() {
     return freq;
   }
   
   synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
   
   synchronized void setState(int s) {
     state = s;
   }
   
   synchronized int getState() {
    return state; 
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc1);
     Oscillator.free(osc2);
     Oscillator.free(osc3);
     Phasor.free(phasor);
     Phasor.free(phasor2);
     Phasor.free(phasor3);
   }
   
 }
