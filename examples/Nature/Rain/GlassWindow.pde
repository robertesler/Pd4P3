
class GlassWindow {
  
  Delay del1 = new Delay();
  Delay del2 = new Delay();
  BandPass bp1 = new BandPass();
  BandPass bp2 = new BandPass();
  BandPass bp3 = new BandPass();
  BandPass bp4 = new BandPass();
  Oscillator osc1 = new Oscillator();
  Oscillator osc2 = new Oscillator();
  Oscillator osc3 = new Oscillator();
  Oscillator osc4 = new Oscillator();
  double bpCf1 = 2007;
  double bpCf2 = 1994;
  double bpCf3 = 1984;
  double bpCf4 = 1969;
  double bpQ = 2.3;
  double f1 = 254;
  double f2 = 669;
  double f3 = 443;
  double f4 = 551;
  double vol = .61;
  double delTime1 = 3.7;
  double delTime2 = 4.2;
  double delread1 = 0;
  double delread2 = 0;

  public GlassWindow() {
     bp1.setQ(bpQ);
     bp2.setQ(bpQ);
     bp3.setQ(bpQ);
     bp4.setQ(bpQ);
     bp1.setCenterFrequency(bpCf1);
     bp2.setCenterFrequency(bpCf2);
     bp3.setCenterFrequency(bpCf3);
     bp4.setCenterFrequency(bpCf4);
     del1.setDelayTime(delTime1);
     del2.setDelayTime(delTime2);
  }
  
  public double perform(double input) {
    double output = 0;
    double oscVol1 = bp1.perform((delread1  * vol));
    double oscVol2 = bp2.perform((delread1  * vol));
    double oscVol3 = bp3.perform((delread2  * vol));
    double oscVol4 = bp4.perform((delread2  * vol));
    double a = (osc2.perform(f2) * oscVol2) + (osc4.perform(f4) * oscVol4);
    double b = (osc1.perform(f1) * oscVol1) + (osc3.perform(f3) * oscVol3);
    delread1 = del1.perform(input + a);
    delread2 = del2.perform(input + b);
    output = (delread1 * vol) + (delread2 * vol);
    return output;
  }
  
  public void free() {
    Delay.free(del1);
    Delay.free(del2);
    BandPass.free(bp1);
    BandPass.free(bp2);
    BandPass.free(bp3);
    BandPass.free(bp4);
    Oscillator.free(osc1);
    Oscillator.free(osc2);
    Oscillator.free(osc3);
    Oscillator.free(osc4);
  }
  
}
