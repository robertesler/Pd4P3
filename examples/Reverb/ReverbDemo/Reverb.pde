/*
This class models the Schroeder reverberator, four comb filters in parallel 
and two allpass filters in series.
*/
class Reverb {

VariableDelay delay1 = new VariableDelay();
VariableDelay delay2 = new VariableDelay();
VariableDelay delay3 = new VariableDelay();
VariableDelay delay4 = new VariableDelay();
VariableDelay delay5 = new VariableDelay();
VariableDelay delay6 = new VariableDelay();
LowPass lop = new LowPass();

double gain1 = .7;
double gain2 = 0.68;
double gain3 = .63;
double gain4 = .58;
double gain5 = .77;
double gain6 = .79;

double del1 = 0;
double del2 = 0;
double del3 = 0;
double del4 = 0;
double allpass1 = 0;
double allpass2 = 0;
//Our interface to the reverberator
double volume = 0; //0-100
double crossover = 5000; //0-100

double out = 0;

//keep this consistent with other Pd++ classes
public double perform(double input) {
    delay1.delayWrite(del1 * gain1);//feedback
    del1 =  delay1.perform(104) + input;
    delay2.delayWrite(del2 * gain2);
    del2 =  delay2.perform(113) + input;
    delay3.delayWrite(del3 * gain3);
    del3 =  delay3.perform(131) + input;
    delay4.delayWrite(del4 * gain4);
    del4 =  delay2.perform(142) + input;
    
  
  double combs = (del1 + del2 + del3 + del4) * .25;//Summing step. Because we have four combs, we divide by four, or * .25
  
  //Allpass filter series
  delay5.delayWrite(allpass1 * gain5);
  allpass1 = delay5.perform(23) + combs; 
  allpass1 *= 1 - (gain5*gain5); //1-g^2
  allpass1 += (gain5*-1) * combs; //-g
  
  delay6.delayWrite(allpass2 * gain6);
  allpass2 = delay6.perform(7.6) + allpass1;
  allpass2 *= 1 - (gain6*gain6);
  allpass2 += (gain6*-1) * allpass1;
  
  out = allpass1 + allpass2;
  
  //Add a simple low pass for a damping effect
  lop.setCutoff(getCrossover());
 
return lop.perform(out);

}

public void setTime() {
    
}

public void setVolume(double v) {
 
  volume = v;
 
}

public double getVolume() {
  return volume;
}   

public void setCrossover(double c) {
  
  crossover = c;
}

public double getCrossover() {
 return crossover; 
}

public void free() {
  VariableDelay.free(delay1);
  VariableDelay.free(delay2);
  VariableDelay.free(delay3);
  VariableDelay.free(delay4);
  VariableDelay.free(delay5);
  VariableDelay.free(delay6);
  LowPass.free(lop);
  }

}
