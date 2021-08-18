import com.pdplusplus.*;

/*
  This sketch shows the standard filters of Pd4P3
  Press keys '1', '2', '3' or '4' to hear the differences
  Use the X/Y mouse to hear the cutoff or bandwidth respectively
  
  1 = Band Pass (freq, Q)
  2 = Low Pass (freq)
  3 = High Pass (freq)
  4 = Stop Band (freq, Q)
  
  This also includes an experimental version of a stop band aka notch filter.

*/
 Pd pd;
 MyMusic music;
 
  int state = 0;
  String banner = "Press 1-4";
  
 void setup() {
   size(640, 360);
   background(0);
   
   
   music = new MyMusic();
   pd = Pd.getInstance(music);
   
   //start the Pd engine thread
   pd.start();
   
 }
 
 void draw() {
  
   float cutoff = map(mouseX, 0, width, 0, 4000);
   music.setCutoff(cutoff);
   float bandwidth = map(mouseY, 0, height, .1, 30);
   music.setBandwidth(bandwidth);
   
   
 // Set background color, noFill and stroke style
  background(0);
  stroke(255);
  strokeWeight(2);
  noFill();
  textSize(12);
  text(str(cutoff) + " Hz, Q = " + str(bandwidth), mouseX, mouseY);
 
   
   if (keyPressed) {
      if(key == '1')
      {
         state = 1;
         banner = "Band Pass";
      }
      if(key == '2')
      {
        state = 2;
        banner = "Low Pass";
      }
      if(key == '3')
      {
         state = 3;
         banner = "High Pass";
      }
      if(key == '4')
      {
         state = 4;
         banner = "Stop Band";
      }
      
   }
   music.setFilter(state);
   textSize(32);
   text(banner, width/2 - 100, 32);
   
 }

 
 public void dispose() {
   //stop Pd engine
   pd.stop();
  println("Pd4P3 audio engine stopped.");
    super.dispose();
}
 
 /*
   A brief demonstration of the standard filters of Pd4P3
   Most filters do what they say OR
   Band Pass: filter out frequencies around a band
   Low Pass: filter out high frequencies (lets lows pass)
   High Pass: filter out low frequencys (lets highs pass)
   Stop Band: filter out a band (stop the band, aka notch filter)
 */
 class MyMusic extends PdAlgorithm {
   
   Noise noise = new Noise();
   BandPass bp = new BandPass();
   LowPass lop = new LowPass();
   HighPass hip = new HighPass();
   Notch notch = new Notch();
   
   int filter = 0;
   float cutoff = 100;
   float bw = 1;
   double out = 0;
   
   void runAlgorithm(double in1, double in2) {
     //We'll use noise to hear the difference
     double n = noise.perform();
     
     switch (getFilter()) {
       case 1:
         bp.setCenterFrequency(getCutoff());
         bp.setQ(getBandwidth());
         outputL = outputR = bp.perform(n); 
         break;
       case 2:
         lop.setCutoff(getCutoff());
         outputL = outputR = lop.perform(n); 
         break;
       case 3:
         hip.setCutoff(getCutoff());
         outputL = outputR = hip.perform(n); 
         break;
       case 4:
         notch.setCenterFrequency(getCutoff());
         notch.setQ(getBandwidth());
         outputL = outputR = notch.perform(n);
         break;
       default: 
          outputL = outputR = n * .5;
      
     }
     
     
   }
  
  //We are using cutoff for both bp's center frequency and lop/hip cutoff
   synchronized void setCutoff(float c) {
     cutoff = c;
   }
   
   synchronized float getCutoff() {
     return cutoff;
   }
   
   //only used with bp
   synchronized void setBandwidth(float b) {
     bw = b;
   }
   
   synchronized float getBandwidth() {
     return bw;
   }
   
   //tells us which filter to process
   synchronized void setFilter(int f) {
     filter = f;
   }
   
   synchronized int getFilter() {
     return filter;
   }
   
   //Free all objects created from Pd4P3 lib
   void free() {
     Noise.free(noise);
     BandPass.free(bp);
     LowPass.free(lop);
     HighPass.free(hip);
     notch.free();//custom class, see the tab
     
   }
   
 }
