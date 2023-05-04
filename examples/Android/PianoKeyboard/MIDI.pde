import android.media.midi.*;
import android.content.pm.PackageManager;
import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

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
   
   private MidiManager m;
   
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
    
   void start(Context context) {
       if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
           m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
           MidiDeviceInfo[] infos = m.getDevices();
           
           //If there are no MIDI devices then move on. 
            if(infos.length > 0)
            {
               for (int i = 0; i < infos.length; i++) {
                MidiDeviceInfo info = infos[i];

                Bundle properties = info.getProperties();
                String manufacturer = properties
                        .getString(MidiDeviceInfo.PROPERTY_MANUFACTURER);
                String product = properties
                        .getString(MidiDeviceInfo.PROPERTY_PRODUCT);
                String name = properties
                        .getString(MidiDeviceInfo.PROPERTY_NAME);
                // myDevices[i] = i + ": " + name;
                println("MIDI", "ID: " + i + " | " + " Input Ports: " + info.getInputPortCount() + " Manufacturer: " + manufacturer
                        + " Product: " + product + " Name: " + name);
              }
            }
         }
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
