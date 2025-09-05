 /*
 I use the following math utils so much I decided to
 just put them in an example.  You can just copy these
 when you need them or use the whole class however
 you like. 
 
 This is probably more just for me so I don't have to
 keep writing these darn methods so many times. 
 
 
 */
 
 class MathUtilities {
 
    //emulate [clip~], a = input, b = low range, c = high range
    public double clip(double a, double b, double c) {
     if(a < b)
       return b;
     else if(a > c)
       return c;
     else
       return a;
    }
  
    public double max(double a, double b) {
     double max = 0;
     if(a < b)
     {
       max = b;
     }
     if(a > b)
     {
       max = a; 
     }
     return max;
   }
   
   public double min(double a, double b) {
     double min = 0;
     if(a > b)
     {
       min = b;
     }
     if(a < b)
     {
       min = a; 
     }
     return min;
   }
 
   //Returns only the decimal portion of a number
   public double wrap(double in) {
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
    
   public float sqrt(float x) {
     float xhalf = 0.5f * x;
     int i = Float.floatToIntBits(x);
     i = 0x5f3759df - (i >> 1);
     x = Float.intBitsToFloat(i);
     x *= (1.5f - xhalf * x * x); 
     return 1.0f / x; // invert to get sqrt(x)
   }
    
     //inverse sqrt
   public float rsqrt(float x) {
     float xhalf = 0.5f * x;
     int i = Float.floatToIntBits(x);
     i = 0x5f3759df - (i >> 1);
     x = Float.intBitsToFloat(i);
     x *= (1.5f - xhalf * x * x);
     return x;
   }
  
 }
