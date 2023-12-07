class Foot {
  
  //for splitphase
  LowPass lop = new LowPass();
  LowPass lop2 = new LowPass();
  Phasor phasor = new Phasor();
  Line line = new Line();
  Textures textures1 = new Textures();
  Textures textures2 = new Textures();
  private double previousActive= 0;
  private double active = 0;
  private double heel = 0;
  private double roll = .173;
  private double ball = 0;
  private double speed = 0;
  
  public double perform(double speed, int texture) {
   double output = 0;
   setSpeed(speed);
   double [] steps = splitphase(speed);
   double foot1 = foot(steps[0]);
   double foot2 = foot(steps[1]);
   //we'll put our textures here
   switch(texture)
   {
      case 0:
      {
        output = textures1.snow(foot1) +  textures2.snow(foot2);
      }
   }
   return output;
  }
  
  private double foot(double f) {
   double x = clip(f, 0, .75) * 1.3333;
   double a = clip(x, 0, .3333) * 3;
   double b = (clip(x, .125, .875) - .125) * 1.333;
   double c = (clip(x, .667, 1) - .667) * 3;
   double f1 = polycurve(a, getHeel()*3);
   double f2 = polycurve(b, getRoll()*3);
   double f3 = polycurve(c, getBall()*3);
   
   return f1 + f2 + f3;
  }
  
  private double polycurve(double input, double foot) {
    double x = input * input * input;
    double y = input * foot;
    double z = 1 - input;
    double s = ( (x * foot) - y ) * z;
    return s * -1.5;
  }
  
  //our march generator
  private double [] splitphase(double speed) {
    double [] output = {0.0f, 0.0f};
    
    if(speed > 0)
    {
      active = 1;
       if(active != previousActive)
       {
         phasor.setPhase(0); 
       }
    }
    else
    {
      active = 0;
    }
    previousActive = active;
    
    //left foot
    lop.setCutoff(1);
    double a = lop.perform(speed);
    double b = phasor.perform( (a + .2) * 3 );
    double c = 1 - (a + .02);
    double m = min(b, c);
    double w = wrap(m * (1/c) + 1e-05);
    double mult = line.perform(active, 500);
    output[0] = w * mult;
    
    //right foot
    double r = min(wrap(b + .5), c);
    double x = r * (1/c);
    double y = wrap(x + 1e-05);
    output[1] = y * mult;
    
    
    return output;
  }
  
 //emulate [clip~], a = input, b = low range, c = high range
 private double clip(double a, double b, double c) {
   if(a < b)
       return b;
      else if(a > c)
       return c;
      else
        return a;
 }
 
  //emulate [max~] a = input, b = input2, always return the higher value
 private double min(double a, double b) {
   double min = 0;
   if(a < b)
   {
     min = a;
   }
   if(a > b)
   {
     min = b; 
   }
   return min;
 }
  
  //free our memory
  public void free() {
    LowPass.free(lop);
    LowPass.free(lop2);
    Phasor.free(phasor);
    Line.free(line);
    textures1.free();//our custom class
    textures2.free();
  }
  
  private double wrap(double input) {
    double frac = input % 1;
   return frac;
  }
  
  public void setSpeed(double s) {
    speed = s;
  }
  
  public void setRoll(double r) {
    roll = r;
  }
  
  private double getSpeed() {
     return speed; 
  }
  
  private double getBall() {
   lop.setCutoff(.5);
   double h = getSpeed() - lop.perform(getSpeed());
   return (h * 1.7) + .5; 
  }
  
  private double getRoll() {
   return roll * 3; 
  }
  
  private double getHeel() {
   return 1 - getBall(); 
  }
  
}
