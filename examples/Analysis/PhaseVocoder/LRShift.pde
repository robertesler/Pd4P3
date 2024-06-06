//This is an implementatin of Pd's lrshift~
class LRShift extends PdMaster {
   
   double[] tmp;
   
   LRShift() {
     tmp = new double[fftWindowSize];  
   }
  
   double[] perform(double[] in, int shift) {
     
     //evaluate shift is not greater than window size (+/-)
    if (shift > this.getFFTWindow())
    {
      shift = this.getFFTWindow();
    }
    if (shift < this.getFFTWindow() * -1)
    {
      shift = this.getFFTWindow() * -1;
    }


    if (shift > 0)
    {
      //zero out the edge bins
      for (int i = this.getFFTWindow() - 1; i > this.getFFTWindow() + shift; i--)
        tmp[i] = 0;
      
        //copy left
      for (int i = 0; i < this.getFFTWindow() - shift; i++)
      {
        tmp[i] = in[i + shift];
      }
    }

    if (shift < 0)
    {

      //zero out the edge bins
      int n = shift * -1;
      for (int i = 0; i < n; i++)
        tmp[i] = 0;
      
        //copy right 
      for (int i = 0; i < this.getFFTWindow() + shift; i++)
      {
        tmp[i - shift] = in[i];
      }
    }

    if (shift == 0)
    {
      tmp = in;
      println("You didn't shift your block. Use a number greater than or less than 0");
    }

    return tmp;
  }
  
}
