class Granulator {
 
  private double grainRate = 0;
  private double phase = 0;
  private double bandwidth = 0; 
  private double vol = 0;
  private double volRand = 0;
  private double size = 0;
  private double sizeRand = 0;
  private double delay = 0;
  private double delayRand = 0;
  private double panRand = 0;
  private double phaseRand = 0.25;
  
  Phasor phasor = new Phasor();
  Cosine cos = new Cosine();
  VariableDelay vd = new VariableDelay(2000);
  RandomHold volume = new RandomHold();
  RandomHold raisedCos = new RandomHold();
  RandomHold [] params = new RandomHold[3];
  
  //These are our initial values
  public Granulator() {
    setGrainRate(30);
    setPhase(.4819);
    setBandwidth(1);
    setVol(.409449);
    setVolRand(.133858);
    setSize(100);
    setSizeRand(0);
    setDelay(500);
    setDelayRand(400);
    setPanRand(.787402);
    params[0] = new RandomHold();
    params[1] = new RandomHold();
    params[2] = new RandomHold();
  }
  
  
  public double [] perform(double input) {
     vd.delayWrite(input);
     double p = phasor.perform(getGrainRate());
     double a = getCosine(p, getBandwidth());
     double b = getVolume(p);
     double [] del = getParameters(p);
     double c = (a * b) * vd.perform(del[0]);
     double [] output = getPanning(c, del[1]);
     return output;
  }
  
  private double [] getParameters(double input) {
     double [] output = new double[2];
     double grain = params[0].perform(input, getSizeRand(), size);
     double grainDel = params[1].perform(input, getDelayRand(), delay);
     double panning = params[2].perform(input, getPanRand(), .5);
     output[0] = (input * grain) + grainDel;
     output[1] = panning;
     return output;
  }
  
  private double getVolume(double input) {
     double output = 0;
     output =  volume.perform(input, getVolRand(), getVol());
     return output;
  }
  
  //raised cosine
  private double getCosine(double input, double bw) {
     double output = 0;
     output = cos.perform( clip((input - .5) * bw, -.5, .5) ) + 1;
     return output * .5;
  }
  
  private double [] getPanning(double input, double pan) {
     double [] output = new double[2];
     output[0] = input * (1 - pan);
     output[1] = input * pan;
     return output;
  }
 
  private void setRandomPhase() {
     phasor.setPhase(random(10000) / 10000);
  }
  
  
  private double clip(double a, double b, double c) {
     if(a < b)
       return b;
     else if(a > c)
       return c;
     else
       return a;
    }
    
    public double getGrainRate() {
        return grainRate;
    }

    public void setGrainRate(double grainRate) {
        this.grainRate = grainRate;
    }

    public double getPhase() {
        return phase;
    }
    
    public void setPhase(double ph) {
     phasor.setPhase(ph);
     phase = ph;
    }  
    
    public double getBandwidth() {
        return bandwidth;
    }

    public void setBandwidth(double bandwidth) {
        this.bandwidth = bandwidth;
    }

    public double getVol() {
        return vol;
    }

    public void setVol(double vol) {
        this.vol = vol;
    }

    public double getVolRand() {
        return volRand;
    }

    public void setVolRand(double volRand) {
        this.volRand = volRand;
    }

    public double getSize() {
        return size;
    }

    public void setSize(double size) {
        this.size = size;
    }

    public double getSizeRand() {
        return sizeRand;
    }

    public void setSizeRand(double sizeRand) {
        this.sizeRand = sizeRand;
    }

    public double getDelay() {
        return delay;
    }

    public void setDelay(double delay) {
        this.delay = delay;
    }

    public double getDelayRand() {
        return delayRand;
    }

    public void setDelayRand(double delayRand) {
        this.delayRand = delayRand;
    }

    public double getPanRand() {
        return panRand;
    }

    public void setPanRand(double panRand) {
        this.panRand = panRand;
    }

  public void free() {
    Phasor.free(phasor);
    Cosine.free(cos);
    VariableDelay.free(vd);
    volume.free();
    raisedCos.free();
    params[0].free();
    params[1].free();
    params[2].free();
  }
}
