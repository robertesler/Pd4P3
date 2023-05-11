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
   private MidiInputPort inputPort;
   
   public boolean useAsMidiDevice = false;
   
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
                
                if(getUseAsMidiDevice())
                {
                   byte[] buffer = new byte[32];
                   int numBytes = 0;
                   int channel = 3; // MIDI channels 1-16 are encoded as 0-15.
                   buffer[numBytes++] = (byte)(0x90 + (channel - 1)); // note on
                   buffer[numBytes++] = (byte)note; // pitch is middle C
                   buffer[numBytes++] = (byte)velocity; // max velocity
                   int offset = 0;
   
                   // post is non-blocking
                   try
                   {
                     inputPort.send(buffer, offset, numBytes);
                   }
                   catch(IOException e)
                   {
                     println(e);
                   }
                }
               
    }
    
   void start(Context context, int deviceID) {
       if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
           m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
           MidiDeviceInfo[] infos = m.getDevices();
           
           /*
            Register callbacks for when a MIDI device is added or removed.
            This way of handling callbacks in deprecated, it still works
            but there are no good examples of how to get the new way of
            handling device callbacks from Android yet.  Ugh!
            */     
           
            m.registerDeviceCallback( new MidiManager.DeviceCallback() {
               public void onDeviceAdded( MidiDeviceInfo info ) {
                         println("new device added: " + info.toString());
                         openNewMidiDevice(m, info);
               }
               public void onDeviceRemoved( MidiDeviceInfo info ) {
                         println("device removed: " + info.toString());
               }
             }, new Handler(Looper.getMainLooper()));
           
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
              
              MidiDeviceInfo info = infos[deviceID];
            
              m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        inputPort = device.openInputPort(0);
                    }
                }
              }, new Handler(Looper.getMainLooper()) );
            
            }
            else
            {
               println("No MIDI devices or services were found!"); 
            }
        
            
         }
   }
   
   /*
   This will be called when a new device is plugged in.
   It will open the new device automatically.
 */
 private void openNewMidiDevice(MidiManager m, MidiDeviceInfo info) {
   
            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        inputPort = device.openInputPort(0);
                        
                    }
                }
              }, new Handler(Looper.getMainLooper()) );  
   
 }
  
   public void setPitchBend(float p) {
       mFrequencyScaler = p;
   }

   public void setVibrato(int v) {
     controlChange = v;
     //byte[] buffer = new byte[32];
     //int numBytes = 0;
     //int channel = 3; // MIDI channels 1-16 are encoded as 0-15.
     //buffer[numBytes++] = (byte)(0xB0 + (channel - 1)); // CC
     //buffer[numBytes++] = (byte)1; //Mod Wheel
     //buffer[numBytes++] = (byte)controlChange; //Value
     //int offset = 0;
   
     //// post is non-blocking
     //try
     //{
     //  inputPort.send(buffer, offset, numBytes);
     //}
     //catch(IOException e)
     //{
     //  println(e);
     //}
   }
   
   public MidiInputPort getMidiInputPort() {
     return inputPort;
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
    
    public void setUseAsMidiDevice(boolean b) {
       useAsMidiDevice = b; 
    }
    
    public boolean getUseAsMidiDevice() {
       return useAsMidiDevice; 
    }
    
}
