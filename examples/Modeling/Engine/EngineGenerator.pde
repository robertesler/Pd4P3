class EngineGenerator {
  
  
  //These are all the default values from the original patch engine003.pd
  private double speed = 0;
  private double mixParabola = 0.929; 
  private double mixCylinders = 0.842;
  private double transmissionDelay1 = 0.125;
  private double transmissionDelay2 = 0.196;
  private double transmissionDelay3 = 0.385;
  private double parabolaDelay = 0.141;
  private double warpDelay = 0.338;
  private double waveguideWarp = 0.629;
  private double waveguideFeedback = 0.448;
  private double wguideLength1 = 0.299;
  private double wguideLength2 = 0.622;
  private double wguideWidth1 = 0.377;
  private double wguideWidth2 = 0.275;
  private double overtonePhase1 = .645;
  private double overtoneFreq1 = 0.275;
  private double overtoneAmp1 = 0.031;
  private double overtonePhase2 = 0.267;
  private double overtoneFreq2 = 0.409;
  private double overtoneAmp2 = 0.110;
  private double overtonePhase3 = 0.732;
  private double overtoneFreq3 = 0.370;
  private double overtoneAmp3 = 0.094;
  
  private long counter = 0;
  
  //for spacewarping
  double ewgfb1 = 0;
  double ewgfb2 = 0;
  
  // This is for our main algorithm, perform()
  VariableDelay vd1 = new VariableDelay();
  VariableDelay vd2 = new VariableDelay();
  VariableDelay vd3 = new VariableDelay();
  VariableDelay vd4 = new VariableDelay();
  VariableDelay vd5 = new VariableDelay();
  Cosine cos = new Cosine();
  Line line = new Line();
  Phasor phasor = new Phasor();
  LowPass lop = new LowPass();
  HighPass hip = new HighPass();
  Wrap wrap1 = new Wrap();
  Wrap wrap2 = new Wrap();
  Wrap wrap3 = new Wrap();
  
  Overtone overtone1 = new Overtone();
  Overtone overtone2 = new Overtone();
  Overtone overtone3 = new Overtone();
  
  // Pd4P3 classes for fourstroke engine (fs)
  VariableDelay fsVd1 = new VariableDelay();
  VariableDelay fsVd2 = new VariableDelay();
  VariableDelay fsVd3 = new VariableDelay(); 
  VariableDelay fsVd4 = new VariableDelay();
  
  Delay fsDel1 = new Delay();
  Delay fsDel2 = new Delay();
  Delay fsDel3 = new Delay();
  Delay fsDel4 = new Delay();
  
  Cosine fsCos1 = new Cosine();
  Cosine fsCos2 = new Cosine();
  Cosine fsCos3 = new Cosine();
  Cosine fsCos4 = new Cosine();
  
  Noise fsNoise = new Noise();
  LowPass fsLop1 = new LowPass();
  LowPass fsLop2 = new LowPass();
  Line fsLine = new Line();
  
  //This is for space warping (spw)
  VariableDelay spwVd1 = new VariableDelay();
  VariableDelay spwVd2 = new VariableDelay();
  VariableDelay spwVd3 = new VariableDelay();
  VariableDelay spwVd4 = new VariableDelay();
  
  HighPass spwHip1 = new HighPass();
  HighPass spwHip2 = new HighPass();
  HighPass spwHip3 = new HighPass();
  
  public EngineGenerator() {
    
  }
  
  double perform() {

    hip.setCutoff(2);
    lop.setCutoff(.2);

    double speedSig = phasor.perform(line.perform(getSpeed()*30, 100));
    vd1.delayWrite(speedSig);
    vd2.delayWrite(speedSig);
    vd3.delayWrite(speedSig);
    vd4.delayWrite(speedSig);
    vd5.delayWrite(speedSig);
    double fse = fourstroke(speedSig);
    double a = parabola(vd1.delayRead(getParabolaDelay() * 100)) * getMixParabola();
    double wp =  cos.perform( vd2.delayRead(getWarpDelay() * 100) );
    double wgw = lop.perform( getSpeed() *  getWaveguideWarp() );
    double b = ((1 - wp) * wgw) + .5;
    double c = (wp * wgw) + .5;
    double d1 = wrap1.perform( vd3.delayRead((getTransmissionDelay2() * 100)) * 16);
    double d = overtone1.perform(d1, getOvertonePhase1(), getOvertoneFreq1(), getOvertoneAmp1());
    double ee = vd4.delayRead(getTransmissionDelay3() * 100) * 4;
    double e1 = wrap2.perform(ee);
    double e = overtone2.perform(e1, getOvertonePhase3(), getOvertoneFreq3(), getOvertoneAmp3());
    double f1 = wrap3.perform( vd5.delayRead((getTransmissionDelay1() * 100)) * 8 );
    double f = overtone3.perform(f1, getOvertonePhase2(), getOvertoneFreq2(), getOvertoneAmp2());
    double spw = spacewarping(a, b, c, d, e, f);
    double out = hip.perform(fse * getMixCylinders());
    return (spw + out) * .5;
  }
  
  /*
  This is totally bonkers, but it's just a a series of delays
  NOTE: in the sub-patch inlets labeled d and c are backwards, as far as I can tell.
  */
  private double spacewarping(double a, double fm1, double fm2, 
  double b, double d, double c) 
  {
    double out = 0;
    
    spwHip1.setCutoff(30);
    spwHip2.setCutoff(200);
    spwHip3.setCutoff(200);
    double e1a = spwHip1.perform(a) + (ewgfb2 * getWaveguideFeedback());
    spwVd1.delayWrite(e1a);//e1a
    double e2a = (spwVd1.perform(getWguideWidth2() * 40) * fm2) + b;
    spwVd2.delayWrite(e2a);//e2a
    ewgfb1 = spwVd2.perform( (getWguideLength1() * 40) * fm1 );
    spwVd3.delayWrite(c + ewgfb1);//e1b
    double e2b = spwVd3.perform(fm1 * (getWguideWidth1()*40)) + d ;
    spwVd4.delayWrite(e2b);//e2b
    ewgfb2 = spwVd4.perform(fm2 * (getWguideLength2() * 40));
    out = spwHip2.perform(ewgfb1 + ewgfb2 + e2a + e2b);
    return spwHip3.perform(out);
  }
  
  private double fourstroke(double speedSig) {
    
     double[] out = new double[4];
     fsLop1.setCutoff(20);
     fsLop2.setCutoff(20);
     double noiseGen = fsLop2.perform( fsLop1.perform( fsNoise.perform() ) );
     double speedScaled = ( (1 - this.getSpeed() ) * 3) + 2;
     
     fsVd1.delayWrite(noiseGen);
     fsVd2.delayWrite(noiseGen);
     fsVd3.delayWrite(noiseGen);
     fsVd4.delayWrite(noiseGen);
     
     double vd1 = fsVd1.perform(5);
     double vd2 = fsVd2.perform(10); 
     double vd3 = fsVd3.perform(15); 
     double vd4 = fsVd4.perform(20); 
     
     double a = fsCos1.perform( (speedSig + (vd1 * .5) ) - .75);
     double b = fsCos2.perform( (speedSig + (vd2 * .5) ) - .5);
     double c = fsCos3.perform( (speedSig + (vd3 * .5) ) - .25);
     double d = fsCos4.perform(  speedSig + (vd4 * .5) );
     
     double s = fsLine.perform(speedScaled, 250);
     
     double w = ( (vd1 * 10) + s)  * a;
     double x = ( (vd2 * 10) + s)  * b;
     double y = ( (vd3 * 10) + s)  * c;
     double z = ( (vd4 * 10) + s)  * d;
     
     out[0] = 1 / ( (w*w) + 1);
     out[1] = 1 / ( (x*x) + 1);
     out[2] = 1 / ( (y*y) + 1);
     out[3] = 1 / ( (z*z) + 1);
     
     return out[0] + out[1] + out[2] + out[3]; 
  }
  
  double parabola(double input) {
     double a = input - .5;
     double b = ((a*a) * -4) + 1;
     return b * 3; 
  }
  
  //emulate [max~] a = input, b = input2, always return the higher value
 
 void free() {
    
    //free main objects
    VariableDelay.free(vd1);
    VariableDelay.free(vd2);
    VariableDelay.free(vd3);
    VariableDelay.free(vd4);
    VariableDelay.free(vd5);
    
    Cosine.free(cos);
    Line.free(line);
    Phasor.free(phasor);
    LowPass.free(lop);
    HighPass.free(hip);
    
    //four stroke engine delete memory
    VariableDelay.free(fsVd1);
    VariableDelay.free(fsVd2);
    VariableDelay.free(fsVd3);
    VariableDelay.free(fsVd4);
    
    Delay.free(fsDel1);
    Delay.free(fsDel2);
    Delay.free(fsDel3);
    Delay.free(fsDel4);
    
    Cosine.free(fsCos1);
    Cosine.free(fsCos2);
    Cosine.free(fsCos3);
    Cosine.free(fsCos4);
    
    Noise.free(fsNoise);
    LowPass.free(fsLop1);
    LowPass.free(fsLop2);
    Line.free(fsLine);
    
    //free space warp
    VariableDelay.free(spwVd1);
    VariableDelay.free(spwVd2);
    VariableDelay.free(spwVd3);
    VariableDelay.free(spwVd4);
    
    HighPass.free(spwHip1);
    HighPass.free(spwHip2);
    HighPass.free(spwHip3);
  }
  
  /*************
  all of our getters/setters to the generator are below
  range is 0-1 for all
  *************/
  
    public void setSpeed(double s) {
      this.speed = s;
    }
  
    public double getSpeed() {
      return speed; 
    }
  
    public void setParabolaDelay(double pd) {
        this.parabolaDelay = pd;
    }
  
    public double getParabolaDelay() {
       return parabolaDelay; 
    }
    
    public void setMixParabola(double mp) {
        this.mixParabola = mp;
    }
  
    public double getMixParabola() {
       return mixParabola; 
    }
  
    public void setMixCylinders(double mc) {
       this.mixCylinders = mc; 
    }
  
    public double getMixCylinders() {
       return mixCylinders; 
    }
  
    public double getTransmissionDelay1() {
        return transmissionDelay1;
    }

    public void setTransmissionDelay1(double transmissionDelay1) {
        this.transmissionDelay1 = transmissionDelay1;
    }

    public double getTransmissionDelay2() {
        return transmissionDelay2;
    }

    public void setTransmissionDelay2(double transmissionDelay2) {
        this.transmissionDelay2 = transmissionDelay2;
    }

    public double getTransmissionDelay3() {
        return transmissionDelay3;
    }

    public void setTransmissionDelay3(double transmissionDelay3) {
        this.transmissionDelay3 = transmissionDelay3;
    }

    public double getWarpDelay() {
        return warpDelay;
    }

    public void setWarpDelay(double warpDelay) {
        this.warpDelay = warpDelay;
    }

    public double getWaveguideWarp() {
        return waveguideWarp;
    }

    public void setWaveguideWarp(double waveguideWarp) {
        this.waveguideWarp = waveguideWarp;
    }

    public double getWaveguideFeedback() {
        return waveguideFeedback;
    }

    public void setWaveguideFeedback(double waveguideFeedback) {
        this.waveguideFeedback = waveguideFeedback;
    }

    public double getWguideLength1() {
        return wguideLength1;
    }

    public void setWguideLength1(double wguideLength1) {
        this.wguideLength1 = wguideLength1;
    }

    public double getWguideLength2() {
        return wguideLength2;
    }

    public void setWguideLength2(double wguideLength2) {
        this.wguideLength2 = wguideLength2;
    }

    public double getWguideWidth1() {
        return wguideWidth1;
    }

    public void setWguideWidth1(double wguideWidth1) {
        this.wguideWidth1 = wguideWidth1;
    }

    public double getWguideWidth2() {
        return wguideWidth2;
    }

    public void setWguideWidth2(double wguideWidth2) {
        this.wguideWidth2 = wguideWidth2;
    }

    public double getOvertonePhase1() {
        return overtonePhase1;
    }

    public void setOvertonePhase1(double overtonePhase1) {
        this.overtonePhase1 = overtonePhase1;
    }

    public double getOvertoneFreq1() {
        return overtoneFreq1;
    }

    public void setOvertoneFreq1(double overtoneFreq1) {
        this.overtoneFreq1 = overtoneFreq1;
    }

    public double getOvertoneAmp1() {
        return overtoneAmp1;
    }

    public void setOvertoneAmp1(double overtoneAmp1) {
        this.overtoneAmp1 = overtoneAmp1;
    }

    public double getOvertonePhase2() {
        return overtonePhase2;
    }

    public void setOvertonePhase2(double overtonePhase2) {
        this.overtonePhase2 = overtonePhase2;
    }

    public double getOvertoneFreq2() {
        return overtoneFreq2;
    }

    public void setOvertoneFreq2(double overtoneFreq2) {
        this.overtoneFreq2 = overtoneFreq2;
    }

    public double getOvertoneAmp2() {
        return overtoneAmp2;
    }

    public void setOvertoneAmp2(double overtoneAmp2) {
        this.overtoneAmp2 = overtoneAmp2;
    }

    public double getOvertonePhase3() {
        return overtonePhase3;
    }

    public void setOvertonePhase3(double overtonePhase3) {
        this.overtonePhase3 = overtonePhase3;
    }

    public double getOvertoneFreq3() {
        return overtoneFreq3;
    }

    public void setOvertoneFreq3(double overtoneFreq3) {
        this.overtoneFreq3 = overtoneFreq3;
    }

    public double getOvertoneAmp3() {
        return overtoneAmp3;
    }

    public void setOvertoneAmp3(double overtoneAmp3) {
        this.overtoneAmp3 = overtoneAmp3;
    }
}
