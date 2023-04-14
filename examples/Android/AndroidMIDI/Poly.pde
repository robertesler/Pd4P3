/*
A polyphonic voice allocator, similar in theory to [poly] in Pd.
This class takes note/vel pairs and keeps track of their noteoff
messages.  When it receives a noteoff it will release that voice
for a new note.
This class does not use "voice stealing" so if you go above the
number of voices allocated then you will get nothing in return,
or just a 0.  
So if that is a concern make sure you allocate it for as many voices
as you think you'll need.  Or change the code to use voice stealing.
*/

class PolyBundle {
     public int voice = -1;
     public int note = 0;
     public int velocity = 0;
}

class Poly {
  
  private PolyBundle pb[];
  int num = 0;
  
  Poly(int v){
      
    pb = new PolyBundle[v];
    num = v;
    
    for(int i = 0; i < num; i++)
    {
      pb[i] = new PolyBundle();
    }
  }
  
  Poly() {
    pb = new PolyBundle[4];
    num = 4;
    
     for(int i = 0; i < num; i++)
    {
      pb[i] = new PolyBundle();
    }
  }
  
  /*
    For this class we need to keep track of which notes have been
    turned off, when they go off they release their voice number.
    When a new note is played it will get the next available voice
    number
  */
  public PolyBundle[] perform(int note, int vel) {
   
      //We have a note on
       if(vel > 0)
       {
         for(int i = 0; i < num; i++)
         {
           //find first available voice #(0-num)
           if(pb[i].voice == -1)
           {
             pb[i].note = note;
             pb[i].velocity = vel;
             pb[i].voice = i;
             break;
           }
           else
           {
              //This is where we could implement voice stealing 
           }
         }
       }
       else
       {
          for(int i = 0; i < num; i++)
         {
           if(pb[i].note == note)
           {
             pb[i].note = note;
             pb[i].velocity = 0;
             pb[i].voice = -1;
           }
         }
       }
    
    
    return pb;
   
    
  }
  
   public double getNumOfVoices() {
    double v = 0;
    for(int i = 0; i < num; i++)
    {
       if(pb[i].voice != -1)
       {
           v++;
       }
    }
    return v;
  }
  
}
