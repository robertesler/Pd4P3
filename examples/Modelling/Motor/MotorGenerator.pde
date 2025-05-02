class MotorGenerator {
  
  private double runtime = .507;
  private double statorLevel = .634;
  private double brushLevel = .333;
  private double rotorLevel = .714;
  private double maxSpeed = .746;
  private double tubeRes = .126;
  private double volume = .236;
  private double timeEnv = 1;
  private boolean go = false;
  //perform
  Phasor phasor = new Phasor();
  
  //for rotor
  Noise rNoise = new Noise();
  BandPass rBp = new BandPass();
  
  //for motorenv
  Line vline = new Line();
 
  //for stator
  Wrap stWrap = new Wrap();
  Cosine stCos = new Cosine();
  
  //for tube res
  Oscillator tOsc = new Oscillator();
  Cosine tCos = new Cosine();
  HighPass tHip1 = new HighPass();
  HighPass tHip2 = new HighPass();
 
  void free() {
    
     Phasor.free(phasor);
    
    //motorenv
     Noise.free(rNoise);
     BandPass.free(rBp);
     Line.free(vline);
     
     //stator
     Cosine.free(stCos);
     
     //tube res
     Oscillator.free(tOsc);
     Cosine.free(tCos);
     HighPass.free(tHip1);
     HighPass.free(tHip2);
  }
  
  public MotorGenerator() {
    
  }
  
  double perform() {
    double out = 0;
  
    if(getGo())
    {  
       timeEnv = vline.perform(1, getRuntime() * 20000);
       if(timeEnv == 1) setGo(false);
       double motor = motorEnvelope(timeEnv);
       double a = phasor.perform( (motor * (getMaxSpeed() * -2000)) );
       double b = (rotor(a) + stator(a)) + (tube(a, motor) * getTubeRes());
       out = (a + b) * getVolume();
    }
    else
    {
       timeEnv = 0; 
       vline.perform(0,0);
       out = 0;
    }
    
    return out;
  }
  
  double motorEnvelope(double input) {
    //time base envelope need as input, 0-1
    double a = input * 2;
    double b = 1 - min(a, 1);
    double bpow6 = b * b * b * b * b * b;
    double c = (max(a, 1) - 1 + bpow6) * -1;
    return c + 1;
  }
  
  double rotor(double drive) {
    
    rBp.setCenterFrequency(4000);
    rBp.setQ(1);
    double a = (rBp.perform(rNoise.perform()) * getBrushLevel()) + getRotorLevel();
    double b = drive * drive * drive * drive;
    return a * b;
  }
  
  double stator(double drive) {
   
    double a = stCos.perform(stWrap.perform((float)drive * 2)); 
    double b = 1 / ((a * a) + 1);
    return (b - .5) * getStatorLevel();
  }
  
  double tube(double amount, double drive) {
    
    tHip1.setCutoff(180);
    tHip2.setCutoff(180);
    double a = (amount * tOsc.perform(178)) + drive;
    double b = tHip2.perform( tHip1.perform( tCos.perform(a) ) );
    return b;
  }
  
    //emulate [max~] a = input, b = input2, always return the higher value
 private double max(double a, double b) {
   double max = 0;
   if(a <= b)
   {
     max = b;
   }
   if(a >= b)
   {
     max = a; 
   }
   return max;
 }
 
 private double min(double a, double b) {
   double min = 0;
   if(a >= b)
   {
     min = b;
   }
   if(a <= b)
   {
     min = a; 
   }
   return min;
   
 }
  
  //getter and setters
   // Getter and Setter for runtime
    public double getRuntime() {
        return runtime;
    }

    public void setRuntime(double runtime) {
        this.runtime = runtime;
    }

    // Getter and Setter for statorLevel
    public double getStatorLevel() {
        return statorLevel;
    }

    public void setStatorLevel(double statorLevel) {
        this.statorLevel = statorLevel;
    }

    // Getter and Setter for brushLevel
    public double getBrushLevel() {
        return brushLevel;
    }

    public void setBrushLevel(double brushLevel) {
        this.brushLevel = brushLevel;
    }

    // Getter and Setter for rotorLevel
    public double getRotorLevel() {
        return rotorLevel;
    }

    public void setRotorLevel(double rotorLevel) {
        this.rotorLevel = rotorLevel;
    }
    
    public double getMaxSpeed() {
       return maxSpeed; 
    }
    
    public void setMaxSpeed(double maxSpeed) {
       this.maxSpeed = maxSpeed; 
    }

    // Getter and Setter for tubeRes
    public double getTubeRes() {
        return tubeRes;
    }

    public void setTubeRes(double tubeRes) {
        this.tubeRes = tubeRes;
    }

    // Getter and Setter for volume
    public double getVolume() {
        return volume;
    }

    public void setVolume(double volume) {
        this.volume = volume;
    }
    
    public boolean getGo() {
       return go; 
    }
    
    public void setGo(boolean go) {
       this.go = go; 
    }
  
}
