//This is an implementatin of Pd's lrshift~
class LRShift extends PdMaster {
   
   double[] tmp;
   
   LRShift() {
     tmp = new double[fftWindowSize];  
   }
  
   double[] perform(double[] block, int value) {
     
     //evaluate shift is not greater than window size (+/-)
     if(value > fftWindowSize)
     {
        value = fftWindowSize;
     }
     if(value < fftWindowSize*-1)
     {
       value = fftWindowSize*-1;
     }
     
     if(value > 0)
     {
      //copy left
      for(int i = 0; i < block.length-value; i++)
      {
         tmp[i] = block[i+value]; 
      }
     }
     
     if(value < 0)
     {
      //copy right 
      for(int i = 0; i < block.length+value; i++)
      {
         tmp[i-value] = block[i]; 
      }
     }
     
     if(value == 0)
     {
        tmp = block;
        println("You didn't shift your block. Use a number greater than or less than 0");
     }
     
     return tmp;
   }
  
}
