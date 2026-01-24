/*
  This is how you can implement a notch filter using BiQuad.
  Math and code is mostly borrowed from:
  (C) Guenter Geiger <geiger@epy.co.at>
  https://github.com/pd-externals/ggee/blob/master/filters/notch.c
  
  It's not super optimized for serious real-time audio but it 
  should do the job for most usage cases.
*/

class Notch extends PdMaster {
     
     private float freq, bw;
     BiQuad biquad = new BiQuad();
  
     public double perform(double input) {
       
       float omega = e_omega(getCenterFrequency(), this.getSampleRate());
       float alpha = e_alpha(getQ() * 0.01, omega);
       float b1 = -2.*cos(omega);
       float b0 = 1;
       float b2 = b0;
       float a0 = 1 + alpha;
       float a1 = -2.*cos(omega);
       float a2 = 1 - alpha;
       
     if (!check_stability(-a1/a0,-a2/a0)) {
       println("notch: filter unstable -> resetting");
       a0=1.;a1=0.;a2=0.;
       b0=1.;b1=0.;b2=0.;
     }
       
       biquad.setCoefficients(-a1/a0, -a2/a0, b0/a0, b1/a0, b2/a0);
       double out = biquad.perform(input);
       return out;
     }
     
     float e_omega(float f, float r) {
       return 2 * PI*(f/r);
     }
     
     float e_alpha(float bw, float omega) {
       return sin(omega) * (float)Math.sinh(0.69314718/2. * bw * omega/sin(omega));
     }
     
     synchronized void setCenterFrequency(float f) {
       freq = f;
     }
     
     synchronized float getCenterFrequency() {
       return freq;
     }
     
     synchronized void setQ(float b) {
       bw = b;
     }
     
     synchronized float getQ() {
       return bw;
     }
     
     public void free() {
        BiQuad.free(biquad); 
     }
  
     public boolean check_stability(float fb1, float fb2) {
       float discriminant = fb1 * fb1 + 4 * fb2;

       if (discriminant < 0) /* imaginary roots -- resonant filter */
       {
      /* they're conjugates so we just check that the product
      is less than one */
          if (fb2 >= -1.0f) return true;
       }
       else    /* real roots */
       {
         /* check that the parabola 1 - fb1 x - fb2 x^2 has a
          vertex between -1 and 1, and that it's nonnegative
          at both ends, which implies both roots are in [1-,1]. */
          if (fb1 <= 2.0f && fb1 >= -2.0f &&
               1.0f - fb1 -fb2 >= 0 && 1.0f + fb1 - fb2 >= 0)
           return true;
       }
       return false;

   } 
  
}
