class ControlFFT extends PdMaster implements Runnable {
 
  rFFT rfft = new rFFT();
  double[] fft  = new double[this.getFFTWindow()];
  Thread scheduler;
  double input = 0;
  boolean play = true;
  
  private ControlFFT() {
     scheduler = new Thread(this);
     scheduler.setName("ControlFFT");
  }
  
  void run() {
    try{
        perform();
    }
    catch (Exception e) {
       e.printStackTrace(); 
    }
  }
  
  void perform() {
    while(play)
       setFFTBlock( rfft.perform(getInput()) );  
  }
  
  synchronized void setFFTBlock (double[] i) {
     fft = i; 
  }
  
  synchronized double[] getFFTBlock() {
     return fft; 
  }
  
  synchronized void setInput(double i) {
     input = i; 
  }
  
  synchronized double getInput() {
     return input; 
  }
  
  public void start() {
     play = true;
     scheduler.start();
  }
  
  public void stop() {
     play = false;
     free(); 
  }
  
  void free() {
    rFFT.free(rfft);
  }
  
}
