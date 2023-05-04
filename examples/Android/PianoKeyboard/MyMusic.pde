class MyMusic extends PdAlgorithm {
   
   //create new Pd4P3 objects like this
   Oscillator osc = new Oscillator();//for vibrato
   int max = 8;
   Synth synths[] = new Synth[max];
   double out = 0;
   int frameCounter = 0;
   
   int [] notes = new int[max];    
   int [] vels = new int[max];
   int [] voices = new int[max];
    
   int controlChange = 0;
   double numOfVoices = 0;
   
    MyMusic() {
     
     for(int i = 0; i < max; i++)
         synths[i] = new Synth(); 
      
   }

   void runAlgorithm(double in1, double in2) {
     
     double out = 0;
     double v = midi.getNumOfVoices();
     double mix = .3;
     double cf = (double)midi.getControlChange()/127.0f;
     cf *= 20;
     double at = (double)midi.getAftertouch()/127.0f; //TODO: use this for something.  
    
     double vibrato;
     notes = midi.getNotes();
     vels = midi.getVelocities();
     voices = midi.getVoices();
     
     //Add simple vibrato using the modulation wheel
     if(cf > 0)
       vibrato = (osc.perform(cf) * .6) + .6;
     else
       vibrato = 1;
    
     //A cheap and dirty way to mix our signals
     if(v > max-2)
         mix = .2;
    
    frameCounter++;
      
     //Sum our synths 
     for(int i = 0; i < max; i++)
     {
       // println(i, notes[i]);
        double f = pd.mtof(notes[i]);
        double amp = (double)vels[i]/127.0f;
        f *= midi.getPitchBend();
        out += synths[i].perform(f, amp*mix, voices[i] == -1?false:true);
     }
    
     outputL = outputR =  out * vibrato ;
  
   }
 
  //Free any Pd4P3 objects you create here.
   void free() {
     Oscillator.free(osc);
     for(int i = 0; i < max; i++)
     {
        synths[i].free(); 
     }
   }
   
 }
