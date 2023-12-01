/*
This is a simple emulation of a metronome.
For this we use a sample-based time calculation.
Another way could be use of a separate thread like System.NanoTime()
*/
class Metro {
 
  private long counter = 0; 
  private double lastRate = 0;
  
  boolean perform(double ms, long sampleRate) {
   boolean bang = false;
   long tick = sampleRate/1000 * (long)ms;
   
   if(lastRate != ms) counter = 0;
   
   if(counter++ == tick)
   {
      counter = 0;
      bang = true;
   }
   lastRate = ms;
   return bang;
  }
  
}
