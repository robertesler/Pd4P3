class Playback extends PdMaster {
  
  SampleHold [] samphold; //6
  TabRead4 [] tabread4; //4
  Cosine [] cos; //2
  Wrap [] wrap; //2 
  Phasor phasor = new Phasor();
  Analysis analysis = new Analysis();
  Line line = new Line();
  double specshift = 0;
  double pitch = 48;
  double time = 4000;
  double loco = 0;
  double [] nophase;
  double invblk = 0;
  double blksize = 0;
  
  
  public Playback() {
    samphold = new SampleHold[6];
    tabread4 = new TabRead4[4];
    cos = new Cosine[2];
    wrap = new Wrap[2];
    blksize = analysis.getWindowSize()/2;
    invblk = 1/blksize;
    
    for(int i = 0; i < 6; i++)
    {
      //we need six samphold~
       samphold[i] = new SampleHold();
       //we need two cos~ and wrap~
       if(i < 2)
        {
           cos[i] = new Cosine();
           wrap[i] = new Wrap();
        }
        //we need four tabread4~
        if(i < 4)
        {
          tabread4[i] = new TabRead4();
        }
    }
  }
  
  double perform() {
      double out = 0;
      double p = this.mtof( this.getPitch() - 12);
      double ph = phasor.perform( p );
      double ln = line.perform(this.getLoco(), this.getTime());
      double sampPeriod = this.getSampleRate()/p;
      double grainSize = this.mtof( (this.getSpecShift() * .125) + 69 ) / 440;
      double w = wrap[0].perform((float)ln);
      double w2 = wrap[1].perform((float)ph + .5);
      
      double a = samphold[0].perform(sampPeriod*grainSize, ph);
      double b = samphold[1].perform(w, ph);
      double c = samphold[2].perform(((ln-w)+.5)*blksize, ph);
      double d = samphold[3].perform(sampPeriod*grainSize, w2);
      double e = samphold[4].perform(w, w2);
      double f = samphold[5].perform(((ln-w)+.5)*blksize, w2);
      
      double offset = a * (ph - .5);
      double cl = clip(a * invblk, 1, 1000) * (ph  - .5);
      double winShape = cos[0].perform(clip(cl, -.5, .5)) + 1;
      double t = tabread4[1].perform(offset + c);
      double sum = tabread4[0].perform(offset + c + blksize) - t;
      double nextBlock = ((b * sum) + t) * winShape;
      double w2timesd = (w2 - .5) * d;
      double cl2 = clip(d*invblk, 1, 1000) * (w2 - .5);
      double winShape2 = cos[1].perform(clip(cl2, -.5, .5)) + 1;
      double t2 = tabread4[3].perform(w2timesd + f);
      double sum2 = tabread4[2].perform(w2timesd + f + blksize) - t2; 
      double copyB = ((e * sum2) + t2) * winShape2;
      out = copyB + nextBlock;

      return out;
  }
  
  void inSample(String file) {
     analysis.createTable(file);
     nophase = analysis.getTable();
     for(int i = 0; i < tabread4.length; i++)
     {
        tabread4[i].setTable(nophase); 
     }
  }

  void setLoco(double l) {
    loco = ((l/100) * this.getSampleRate())/blksize; 
    line.perform(0,0);
  }
  
  double getLoco() {
     return loco; 
  }
  
  void setPitch(double p) {
     pitch = p; 
  }
  
  double getPitch() {
     return pitch; 
  }
  
  void setTime(double t) {
     time = t; 
  }
  
  double getTime() {
     return time;
  }
    
  void setSpecShift(double spec) {
     specshift = spec; 
  }
  
  double getSpecShift() {
     return specshift; 
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
  
  void free() {
    
    Phasor.free(phasor);
    analysis.free();
    Line.free(line);
    for(int i = 0; i < 6; i++)
    {
       SampleHold.free(samphold[i]);
       if(i < 2)
        {
           Cosine.free(cos[i]);
           //we don't need to free Wrap
        }
        if(i < 4)
        {
          TabRead4.free(tabread4[i]);
        }
    }
    
    
  }
  
}
