//This is an implementatin of Pd's lrshift~
class LRShift extends PdMaster {
   
   double[] tmp;
   
   LRShift() {
     tmp = new double[this.getFFTWindow()];  
   }
  
   double[] perform(double[] block, int value) {
     
     //evaluate shift is not greater than window size (+/-)
     if(value > this.getFFTWindow())
     {
        value = this.getFFTWindow();
     }
     if(value < this.getFFTWindow()*-1)
     {
       value = this.getFFTWindow()*-1;
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
