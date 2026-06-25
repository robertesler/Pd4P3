import com.pdplusplus.*;

/*
This is an example of using Chebyshev polynomials for audio
synthesis.  Chebyshev polynomials are not something that most
musicians or artists are familiar with, but they are handy in
creating slick and simple synthesizers.  

Basically, this is wavetable synthesizer, but we use a sine wave
to read through our table, which gives us cos(n*F), or think of 
Chebyshev as a function that can generate an oscillator with a
pure harmonic at n*F. 
If you feed a cosine into the Chebyshev polynomial of order n, 
you get a cosine at n times the frequency.
These are the first 6 polynomials.
T_n(x):
T_1(x)  =  x  
T_2(x)  =  2x^2-1  
T_3(x)  =  4x^3-3x  
T_4(x)  =  8x^4-8x^2+1  
T_5(x)  =  16x^5-20x^3+5x  
T_6(x)  =  32x^6-48x^4+18x^2-1.  

Move the mouse for feedback:
X-axis = frequency
Y-axis = index volume
Keys 1-6 = polynomial number

*/

//declare Pd and create new class that inherits PdAlgorithm
 Pd pd;
 MyMusic music;
 
double [] chebyTable = new double[259];//+4 for interpolation
float[] output;
int state = 1;

 void setup() {
   size(640, 360);
   background(255);
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   setChebyshev(1);
   
 }
 
 void draw() {
   // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  
  textSize(24);
  text("Polynomial n = " + state, 50, 50);
  
  music.setFreq( map(mouseX, 0, width, 200, 600) );
  music.setIndex( map(mouseY, height, 0, 100, 25) );
  
  //draw cheby table
  beginShape();
  for(int i = 0; i < chebyTable.length; i++){
    vertex(
      map(i, 0, chebyTable.length, width, 0),
      map((float)chebyTable[i], -1, 1, 0, height)
    );
  }
  endShape(); 
  
  output = music.getOutput();
  
  //draw output
  stroke(140);
  beginShape();
  for(int i = 0; i < output.length; i++){
    vertex(
      map(i, 0, output.length, width, 0),
      map(output[i], -1, 1, 0, height)
    );
  }
  endShape(); 
 }
 
 void mousePressed() {
    music.setBang(true); 
 }
 
 //keys 1-6 set our polynomials
 void keyPressed() {
    if(key == '1')
    {
      setChebyshev(1);
      state = 1;
    }
    if(key == '2')
    {
      setChebyshev(2);
      state = 2;
    }
    if(key == '3')
    {
      setChebyshev(3);
      state = 3;
    }
    if(key == '4')
    {
      setChebyshev(4);
      state = 4;
    }
    if(key == '5')
    {
      setChebyshev(5);
      state = 5;
    }
    if(key == '6')
    {
      setChebyshev(6);
      state = 6;
    }
 }
 
 /*
  This method sets the chebyTable to polynomials 1-6
 */
 void setChebyshev(int poly) {
   
    switch(poly)
    {
       case 1: 
       {
          println("The first polynomial is just y = x, not that interesting.");
          for(int i = 0; i < chebyTable.length; i++)
          {
            float x = (float)(i-129)/128;
            chebyTable[i] = x;
            music.setTable(chebyTable);
          }
          break;
       }      
       case 2: 
       {
          for(int i = 0; i < chebyTable.length; i++)
          {
            
            float x = (float)(i-129)/128;
            chebyTable[i] = 2 * x*x - 1;
          } 
          music.setTable(chebyTable);
          break;
       }
       case 3: 
       {
          for(int i = 0; i < chebyTable.length; i++)
          {
            
            float x = (float)(i-129)/128;
            chebyTable[i] = 4 * pow(x,3) - 3 * x;
          } 
          music.setTable(chebyTable);
          break;
       }
       case 4: 
       {
          for(int i = 0; i < chebyTable.length; i++)
          {
            float x = (float)(i-129)/128;
            chebyTable[i] = 8 * pow(x,4) - 8 * pow(x,2) + 1;
          } 
          music.setTable(chebyTable);
          break;
       }
       case 5: 
       {
          for(int i = 0; i < chebyTable.length; i++)
          {
            float x = (float)(i-129)/128;
            chebyTable[i] = 16 * pow(x,5) - 20 * pow(x,3) + 5*x;
          } 
          music.setTable(chebyTable);
          break;
       }
       case 6: 
       {
          for(int i = 0; i < chebyTable.length; i++)
          {
            float x = (float)(i-129)/128;
            chebyTable[i] = 32 * pow(x,6) - 48 * pow(x,4) + 18*x*x -1;
          } 
          music.setTable(chebyTable);
          break;
       }
       default:
         println("There is no " + poly + " Chebyshev polynomial.");
    }
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
   
   double freq = 220;
   double index = 75;
   Oscillator osc = new Oscillator();
   Line line = new Line();
   Line line2 = new Line();
   HighPass hip = new HighPass();
   TabRead4 tabread = new TabRead4();
   double [] chebyTable = new double[259];  //+4 points for interpolation
   boolean bang = false;
   double env = 0;
   //for graphing
   int block = 1024; //change this to bigger or small to get better graphing
   float[] writeOutput = new float[block];
   int counter = 0;
   
   public MyMusic() {
      hip.setCutoff(3);
   }
   
   //All DSP code goes here
   void runAlgorithm(double in1, double in2) {
     double iter = ((osc.perform(getFreq()) * line.perform(getIndex(), 100)) * 128) + 129;
     double tab = tabread.perform(iter);
     double out = hip.perform(tab); 
     
     //our ring buffer
     writeOutput[counter++] = (float)out;
     if(counter == block)
     {
       setOutput(writeOutput);
       counter = 0;
     }
     
     if(getBang())
        env = line2.perform(1, 20); 
     else
        env = line2.perform(0, 750); 
     
     if(env == 1)
        setBang(false);
        
     outputL = outputR = out * env;
     
   }
   
   synchronized boolean getBang() {
      return bang;
   }
   
   synchronized void setBang(boolean b) {
      bang = b; 
   }
   
   synchronized void setOutput(float[] o) {
      writeOutput = o; 
   }
   
   synchronized float[] getOutput() {
     
    return writeOutput; 
   }
  
   synchronized void setTable(double [] ct)  {
      chebyTable = ct; 
      tabread.setTable(chebyTable);
   }
   
   synchronized double [] getTable() {
      return chebyTable;  
   }
  
  //We use synchronized to communicate with the audio thread
   synchronized void setFreq(double f) {
     freq = f;
   }
   
   synchronized double getFreq() {
     return freq;
   }
   
   synchronized void setIndex(double i) {
     index = i;
   }
   
   synchronized double getIndex() {
     return index/100;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Oscillator.free(osc);
     Line.free(line);
     Line.free(line2);
     HighPass.free(hip);
     TabRead4.free(tabread);
   }
   
 }
