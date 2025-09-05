//This class mimic's Pd's wrap~ object
class Wrap {

  
  double perform(double in) {
     double out = 0;
     int k;
     double f = in;
     f = ((f > Integer.MAX_VALUE || f < Integer.MIN_VALUE) ? 0. : f);
     k = (int)f;
     if( k <= f)
       out = f-k;
     else
       out = f - (k-1);
       
     return out;
  }
  
}
