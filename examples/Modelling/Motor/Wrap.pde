//This class mimic's Pd's wrap~ object, maybe it's time to include this with the package...??
class Wrap {

  
  float perform(float in) {
     float out = 0;
     int k;
     float f = in;
     f = ((f > Integer.MAX_VALUE || f < Integer.MIN_VALUE) ? 0. : f);
     k = (int)f;
     if( k <= f)
       out = f-k;
     else
       out = f - (k-1);
       
     return out;
  }
  
}
