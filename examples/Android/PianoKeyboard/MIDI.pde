class MIDI {
   private int max = 8;
   private int note = 0;
   private int velocity = 0;
   private int [] notes = new int[max];    
   private int [] vels = new int[max];
   private int [] voices = new int[max]; 
   private int controlChange = 0;
   private int aftertouch = 0;
   private float mFrequencyScaler = 1;
   private double numOfVoices = 0;
   private Poly poly = new Poly(max);
   private PolyBundle [] pb = new PolyBundle[max];
   
   public void sendNote(int noteIndex, int vel) {
                note = noteIndex;
                velocity = vel;
                pb = poly.perform(note, velocity);
                
                for(int i = 0; i < max; i++)
                {
                   notes[i] = pb[i].note;
                   vels[i] = pb[i].velocity;
                   voices[i] = pb[i].voice;
                }
                
                numOfVoices = poly.getNumOfVoices();
    }
  
   public void setPitchBend(float p) {
       mFrequencyScaler = p;
   }

   public void setVibrato(int v) {
     controlChange = v;
   }

    public double getPitchBend() {
      return mFrequencyScaler;
    }
    
    public int[] getNotes() {
       return notes; 
    }
    
    public int[] getVelocities() {
       return vels; 
    }
    
    public int[] getVoices() {
       return voices;
    }
    
    public int getControlChange() {
       return controlChange; 
    }
    
    public int getAftertouch() {
       return aftertouch; 
    }
   
    public double getNumOfVoices() {
       return numOfVoices; 
    }
    
}
