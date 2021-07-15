class Analysis extends PdMaster {
 Sigmund sigmund = new Sigmund("peaks", 10); 
 SigmundPackage sp = new SigmundPackage();
 double pitch = 0;
 double envelope = 0;
 double peaks[][] = new double[10][5];
 String noted = "NA";
 
 
 /*
   Sigmund returns a class called SigmundPackage.  This conforms to the C++ struct
   used in the native library.  You can read more here: https://github.com/robertesler/Pd4P3/blob/main/src/com/pdplusplus/SigmundPackage.java
   The peaks and tracks are put into double arrays, which are ordered from the 
   loudest to softest, each row includes five values.
   [0] = the order of your placement from loud to soft, so basically the same as the index
   [1] = the frequency
   [2] = the linear amplitude of the frequency, value 0-1
   [3] = the real value of the sinusoid
   [4] = the imaginary value of the sinusoid
 */
 public void perform(double input) {
   sp = sigmund.perform(input);
    peaks = sp.peaks;
    pitch = sp.pitch;
    envelope = sp.envelope;
   //println(this.mtof(sp.pitch) + " | " + sp.envelope);
 }

  synchronized void setPitch(double p) {
   pitch = this.mtof(p);//Sigmund outputs MIDI notes
 }
 
 synchronized double getPitch() {
   return pitch;
 }
 
 synchronized void setEnvelope(double e) {
    envelope = e; 
 }
 
 synchronized double getEnvelope() {
   return envelope;
 }
 
 synchronized double[][] getPeaks() {
   return peaks;
 }
 
 public void free() {
    Sigmund.free(sigmund); 
 }
 
}
