/*
This wind generator was inspired by Andy Farnell's
wind example from his book "Designing Sound".
*/

class WindGen {
  
 private Noise noise = new Noise();
 private VariableDelay vdMaster = new VariableDelay();
 private VariableDelay vdBldg = new VariableDelay();
 private VariableDelay vdDoor = new VariableDelay();
 private VariableDelay vdDoor2 = new VariableDelay();
 private VariableDelay vdBranches = new VariableDelay();
 private VariableDelay vdBranches2 = new VariableDelay();
 private VariableDelay vdLeaves = new VariableDelay();
 
 private BandPass bpBldg = new BandPass();
 private BandPass bpDoor = new BandPass();
 private BandPass bpDoor2 = new BandPass();
 
 private LowPass lopDoor1 = new LowPass();
 private LowPass lopDoor2 = new LowPass();
 private LowPass lopLeaves1 = new LowPass();
 private LowPass lopLeaves2 = new LowPass();
 
 private HighPass hipTree = new HighPass();
 
 private VoltageControlFilter vcfBranches = new VoltageControlFilter();
 private VoltageControlFilter vcfBranches2 = new VoltageControlFilter();
 
 private Oscillator osc = new Oscillator();
 private Oscillator osc2 = new Oscillator();
 
 private Cosine cos = new Cosine();
 private Cosine cos2 = new Cosine();
 
 private RealZero rzero = new RealZero();
 
 private WindSpeed windspeed = new WindSpeed();
 
 private double [] doorways = new double[2];
 private double [] doorways2 = new double[2];
 private double [] buildings = new double[2];
 private double [] branches = new double[2];
 private double [] branches2 = new double[2];
 private double [] leaves = new double[2];

 
 private int block = 512;
 private int counter = 0;
 private double [] windOutput = new double[block];
 
 public double [] perform() {
   
   double ws = windspeed.perform(.1);//generate our windspeed
   //This is for graphing the windspeed to our main graphics window
   windOutput[counter++] = ws;  
   if(counter == block) counter = 0;
    
   //generate our delays
   vdLeaves.delayWrite(ws);
   vdDoor.delayWrite(ws);
   vdDoor2.delayWrite(ws);
   vdBldg.delayWrite(ws);
   vdBranches.delayWrite(ws);
   vdBranches2.delayWrite(ws);
   double wsLeaves = vdLeaves.perform(3000);
   double wsDoor = vdDoor.perform(100);
   double wsDoor2 = vdDoor2.perform(300);
   double wsBldg = vdBldg.perform(0);
   double wsBranches = vdBranches.perform(500);
   double wsBranches2 = vdBranches2.perform(900);
   
   double n = noise.perform();//shared white noise generator
   double [] out = new double[2];//left = [0] right = [1]
   
   //get our wind portfolio
   doorways = doorways(wsDoor, n);
   doorways2 = doorways2(wsDoor2, n);
   buildings = buildings(wsBldg, n);
   branches = branches(wsBranches, n);
   branches2 = branches2(wsBranches2, n);
   leaves = leaves(wsLeaves, n);
   
   //add them all together and scale
   out[0] = (doorways[0] + doorways2[0] +  buildings[0] + branches[0] + branches2[0] + leaves[0]) * .45;
   out[1] = (doorways[1] + doorways2[1] +  buildings[1] + branches[1] + branches2[1] + leaves[1]) * .45;
   
   return out;
 }
 
 public double [] getWindOutput() {
    return windOutput; 
 }
 
 private double [] buildings(double ws, double n) {
   
   double [] out = new double[2];

   bpBldg.setCenterFrequency(800);
   double a = ws + .2;
   double b = a * bpBldg.perform (n);
   double c = rzero.perform(b, clip(a*.6, 0, .99)) * .2;
   out = fcpan(c, .51); // left [0], right [1]
   return out;
 }
 
 private double [] doorways(double ws, double n) {
   
   double [] out = new double[2];
   
   /*
   Doorway #1
   */
   bpDoor.setCenterFrequency(400);
   bpDoor.setQ(40);
   lopDoor1.setCutoff(.5);
   double a = lopDoor1.perform( cos.perform( ((clip(ws, .35, .6) - .35) * 2) - .25));
   double b = (bpDoor.perform(n) * a) * 2;
   double c = osc.perform( (a * 200) + 30 );
   double d = b * c;
   out = fcpan(d, .91);
   return out;
 }
 
 private double [] doorways2(double ws, double n) {
   
   double [] out = new double[2];
   
   /*
   Doorway #2
   */
   bpDoor2.setCenterFrequency(200);
   bpDoor2.setQ(40);
   lopDoor2.setCutoff(.1);
   double e = lopDoor2.perform( cos.perform( ((clip(ws, .25, .5) - .25) * 2) - .25));
   double f = (bpDoor.perform(n) * e) * 2;
   double g = osc2.perform( (e * 100) + 20 );
   double h = f * g;
   out = fcpan(h, .03);
   
   return out;
 }
 
  private double [] branches(double ws, double n) {
  
   double [] out = new double[2];
   double [] vcfOut = new double[2];

   /*
   Branches/Wires #1
   */
   vcfBranches.setQ(60);
   double vd = ws;
   double cf = ((vd * 400) + 600);
   vcfOut = vcfBranches.perform(n, cf);
   double a = vcfOut[0] * ( (vd + .12) * (vd + .12) );
   double b = a * 1.2;
   out = fcpan(b, .28);
   
   return out;
   
  }
 
 private double [] branches2(double ws, double n) {
  
   double [] out = new double[2]; 
   double [] vcfOut2 = new double[2];
 
   /*
   Branches/Wires #2
   */
   vcfBranches2.setQ(60);
   double vd2 = ws;
   double cf2 = ((vd2 * 1000) + 1000);
   vcfOut2 = vcfBranches2.perform(n, cf2);
   double c = vcfOut2[0] * ( vd2 * vd2 );
   double d = c * 2;
   out = fcpan(d, .64);
  
   return out;
 }
 
 private double [] leaves(double ws, double n) {
   
   double [] out = new double[2];

   lopLeaves1.setCutoff(.07);
   lopLeaves2.setCutoff(4000);
   hipTree.setCutoff(200);
   double a = lopLeaves1.perform(ws + .3);
   double b = 1 - (a * .4);
   double c = lopLeaves2.perform( hipTree.perform(( max(n, b) - b) * b)) * (a - .2);
   double d = c * .8;
   out = fcpan(d, .71);
   return out;
 }
 
 private double [] fcpan(double in, double val) {
   double left = 0;
   double right = 0;
   double [] out = new double[2];
   
   //This pans our signal left or right based on the val
   left = in * cos.perform ( ((val * .25) - .25) - .25 );
   right = in * cos.perform ( ((val * .25) - .25) );
   out[0] = left;
   out[1] = right;
   return out;
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
 private double max(double a, double b) {
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

 
 public void free() {
  Noise.free(noise); 
  
  VariableDelay.free(vdMaster);
  VariableDelay.free(vdBldg);
  VariableDelay.free(vdDoor);
  VariableDelay.free(vdDoor2);
  VariableDelay.free(vdBranches);
  VariableDelay.free(vdBranches2);
  VariableDelay.free(vdLeaves);
  
  BandPass.free(bpBldg);
  BandPass.free(bpDoor);
  BandPass.free(bpDoor2);
  
  LowPass.free(lopDoor1);
  LowPass.free(lopDoor2);
  LowPass.free(lopLeaves1);
  LowPass.free(lopLeaves2);
  
  HighPass.free(hipTree);
  
  VoltageControlFilter.free(vcfBranches);
  VoltageControlFilter.free(vcfBranches2);
  
  Oscillator.free(osc);
  Oscillator.free(osc2);
  
  Cosine.free(cos);
  Cosine.free(cos2);
  
  //local class not from Pd4P3
  windspeed.free();
 }
  
}
