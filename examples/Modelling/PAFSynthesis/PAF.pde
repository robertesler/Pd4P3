/*
This class uses the Phase Aligned Format Synthesis or PAF.
It's a kind of fancy FM synth with a single phasor,
then ring modulated at the very end with a bell curve.
*/

class PAF extends PdMaster {

  Phasor phasor = new Phasor();
  SampleHold samphold = new SampleHold();
  Oscillator osc = new Oscillator();
  Cosine cos1 = new Cosine();
  Cosine cos2 = new Cosine();
  Cosine cos3 = new Cosine();
  Line line1 = new Line();
  Line line2 = new Line();
  TabRead4 tabread = new TabRead4();
  HighPass hip = new HighPass();
  Wrap wrap = new Wrap();
  int tabSize = 200;
  double[] bellCurve = new double[tabSize];//Gaussian curve
  double phase = 0;
  double phase1 = 0;
  double phase2 = 0;
  double phase3 = 0;
  double gauss = 0;
  double paf = 0;
  double modulator = 0;
  double ring = 0;
  
  public double perform(double f, double cf, double index) {
    
    /*
    This is our PAF synthesis
    x[n] = g(a*sin(w/2)) * (p*cos(k*w) + q*cos((k + 1) * w))
    g = gaussian curve
    w = fundamental frequency (phasor)
    a = modulation index
    k = samphold( cf, w ) - q
    q = wrap( samphold( cf, w ) )
    p = 1 - q
    */
    
    //Keep in mind cos.perform(x) - .25 is a sine wave
    phase = phasor.perform(f);
    modulator = (cos1.perform((phase * .5) - .25) * line1.perform(index, 50));
    gauss = tabread.perform(modulator + tabSize/2);
    phase1 = samphold.perform(line2.perform(cf, 50), phase);
    double wrapPhase1 = wrap.perform((float)phase1);
    phase1 = phase1 - wrapPhase1;
    phase1 = phase * phase1;
    phase2 = phase1 + phase;
    double cosPhase1 = cos2.perform(phase1);
    phase3 = (cos3.perform(phase2) - cosPhase1) * wrapPhase1;
    double carrier = phase3 + cosPhase1;
    ring = carrier * gauss;
    paf = hip.perform(ring);
   
    return paf;
  }
  
  public void setSynth() {
   /*
   Here we will also make our wave shaper table, a Gaussian bell curve
   */
    for(int i = 0; i < tabSize; i++)
    {
        float f = ((float)i-100.0)/25.0;
        bellCurve[i] = exp(-f*f);        
    }
    
    tabread.setTable(bellCurve);
    hip.setCutoff(5);//cut DC

    
  }
  
  
 
  public void free() {
    
    Phasor.free(phasor);
    SampleHold.free(samphold);
    Oscillator.free(osc);
    Cosine.free(cos1);
    Cosine.free(cos2);
    Cosine.free(cos3);
    Line.free(line1);
    Line.free(line2);
    TabRead4.free(tabread);
    HighPass.free(hip);
     //we don't need to free Wrap...
  }
  
}
