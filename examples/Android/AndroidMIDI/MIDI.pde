import android.content.Context;
import android.content.pm.PackageManager;
import android.media.midi.*;
import android.os.Bundle;

import android.os.Handler;
import android.os.Looper;
import java.util.Set;
import java.util.concurrent.Executor;

    
class MIDI extends MidiReceiver {
   
   private MyReceiver receiver;
   private MidiEventScheduler mEventScheduler;
   private MidiConstants mConstants = new MidiConstants();
   private MidiFramer mFramer;
   private boolean printData = true;
   private int note = 0;
   private int velocity = 0;
   private int channel = 0;
   private float mFrequencyScaler = 1.0f;
   private float mBendRange = 2.0f; // semitones
   private int mProgram;
   private int mMidiByteCount;
   private float[] mBuffer = null;
   private int max = 8;
   private Poly poly = new Poly(max);
   private PolyBundle [] pb = new PolyBundle[max];
   
   private int [] notes = new int[max];    
   private int [] vels = new int[max];
   private int [] voices = new int[max]; 
   private int controlChange = 0;
   private int aftertouch = 0;
   private double numOfVoices = 0;
   
   public String midiString = "N/A";
   public String midiCCString = "N/A";
   public String midiPitchBendString = "N/A";
   public String midiAftertouchString = "N/A";
   public String [] myDevices;
   
   public MIDI() {
       receiver = new MyReceiver();
       mFramer = new MidiFramer(receiver);
    
        for(int i = 0; i < max; i++)
        {
           pb[i] = new PolyBundle();
           notes[i] = 0;
           vels[i] = 0;
           voices[i] = 0;
        }
        
    }

   
   /* This will be called when MIDI data arrives. */
    
    @Override
    public void onSend(byte[] data, int offset, int count, long timestamp)
            throws IOException {
        if (mEventScheduler != null) {
            if (!mConstants.isAllActiveSensing(data, offset, count)) {
                mEventScheduler.getReceiver().send(data, offset, count,
                        timestamp);
                byte command = (byte) (data[0] & MidiConstants.STATUS_COMMAND_MASK);
                int channel = (byte) (data[0] & MidiConstants.STATUS_CHANNEL_MASK);
               // println("MIDI", command + " | " + channel + " | " + data[offset+1] + " | " + data[offset+2]);
            }
        }
        mMidiByteCount += count;
    }
    
   
   class MyReceiver extends MidiReceiver {
     
       public MyReceiver() {
          
       }
  
        @Override
        public void onSend(byte[] data, int offset,
                           int count, long timestamp) throws IOException {
            
            byte command = (byte) (data[0] & MidiConstants.STATUS_COMMAND_MASK);
            int channel = (byte) (data[0] & MidiConstants.STATUS_CHANNEL_MASK);
            switch (command) {
            case MidiConstants.STATUS_NOTE_OFF:
                noteOff(channel, data[1], data[2]);
                break;
            case MidiConstants.STATUS_NOTE_ON:
                noteOn(channel, data[1], data[2]);
                break;
            case MidiConstants.STATUS_PITCH_BEND:
                int bend = (data[2] << 7) + data[1];
                pitchBend(channel, bend);
                break;
            case MidiConstants.STATUS_CONTROL_CHANGE:
                controlChange(channel, data[1], data[2]);
            case MidiConstants.STATUS_PROGRAM_CHANGE:
                mProgram = data[1];
                break;
            case MidiConstants.STATUS_POLYPHONIC_AFTERTOUCH:
                aftertouch(channel, data[1], data[2]);
                break;
            case MidiConstants.STATUS_CHANNEL_PRESSURE:
                aftertouch(channel, data[1], data[2]);
                break;
            default:
                break;
            }
        }
           
       
    }//end class MyReceiver
    
    
 /*
   This will open the MIDI device with at least one output port.  
   If you have other services or devices with an output port, 
   this will open the first one.
   Use list() to see your devices...
 */   
 public void start(Context context, MidiReceiver midi) {
        
        stop();

        //Check if this device has MIDI first
        if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
            MidiManager m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
            int myDevice = -1;
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
                         openNewMidiDevice(m, info, midi);
               }
               public void onDeviceRemoved( MidiDeviceInfo info ) {
                         println("device removed: " + info.toString());
               }
             }, new Handler(Looper.getMainLooper()));
             
             myDevices = new String[infos.length];
             
            //If there are no MIDI devices then move on. 
            if(infos.length > 0)
            {
              mEventScheduler = new MidiEventScheduler();
               for (int i = 0; i < infos.length; i++) {
                MidiDeviceInfo info = infos[i];

                Bundle properties = info.getProperties();
                String manufacturer = properties
                        .getString(MidiDeviceInfo.PROPERTY_MANUFACTURER);
                String product = properties
                        .getString(MidiDeviceInfo.PROPERTY_PRODUCT);
                String name = properties
                        .getString(MidiDeviceInfo.PROPERTY_NAME);
                 myDevices[i] = i + ": " + name;
                println("MIDI", "ID: " + i + " | " + " Output Ports: " + info.getOutputPortCount() + " Manufacturer: " + manufacturer
                        + " Product: " + product + " Name: " + name);

                if (info.getOutputPortCount() > 0 && myDevice == -1) {
                    myDevice = i;
                }
            }

            MidiDeviceInfo info = infos[myDevice];
            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        MidiOutputPort outputPort = device.openOutputPort(0);
                        outputPort.connect(midi);

                    }
                }
              }, new Handler(Looper.getMainLooper()) );
            }
            else
            {
               println("No MIDI devices or services were found!"); 
            }
        }

    }//end start midi
 
 /*
  Alternatively we can specify which device we want to connect.
  This could be coupled with listing the devices, this.list(), and having the
  user choose which they want to use.  Use deviceID to open 
  the specific output port.
 */
  public void start(Context context, MidiReceiver midi, int deviceID, int portNumber) {
        
        stop();
        
        //Check if this device has MIDI first
        if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
            MidiManager m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);

            MidiDeviceInfo[] infos = m.getDevices();
            mEventScheduler = new MidiEventScheduler();
            /*
            Register callbacks for when a MIDI device is added or removed.
            This way of handling callbacks in deprecated, it still works
            but there are no good examples of how to get the new way of
            handling device callbacks from Android yet.  Ugh!
            */     
           
            m.registerDeviceCallback( new MidiManager.DeviceCallback() {
               public void onDeviceAdded( MidiDeviceInfo info ) {
                         println("new device added: " + info.toString());
                         openNewMidiDevice(m, info, midi);
               }
               public void onDeviceRemoved( MidiDeviceInfo info ) {
                         println("device removed: " + info.toString());
               }
             }, new Handler(Looper.getMainLooper()));
             
             
             myDevices = new String[infos.length];
             
            //If there are no MIDI devices then move on. 
            if(infos.length > 0)
            {
               for (int i = 0; i < infos.length; i++) {
                MidiDeviceInfo info = infos[i];
                Bundle properties = info.getProperties();
                String name = properties.getString(MidiDeviceInfo.PROPERTY_NAME);
                 myDevices[i] = i + ": " + name;
               }
            }
            else
            {
               println("No MIDI devices or services were found."); 
            }
             
             
            MidiDeviceInfo info = infos[deviceID];
            
            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        MidiOutputPort outputPort = device.openOutputPort(portNumber);
                        outputPort.connect(midi);
                        

                    }
                }
              }, new Handler(Looper.getMainLooper()) );
            }
            else
            {
               println("No MIDI devices or services were found!"); 
            }
        

    }//end start midi
 
 /*
   This will print out a list of your MIDI devices and services
   A device is most likely a hardware controller plugged into 
   your phone or tablet via USB.
   A service can be another app that supports MIDI input.
 */
 public void list(Context context) {
   

        if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {

            MidiManager m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
            MidiDeviceInfo[] infos = m.getDevices();
            
            myDevices = new String[infos.length];
             
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
                 myDevices[i] = i + ": " + name;
                println("MIDI", "ID: " + i + " | " + " Output Ports: " + info.getOutputPortCount() + " Manufacturer: " + manufacturer
                        + " Product: " + product + " Name: " + name);
               }
            }
            else
            {
               println("No MIDI devices or services were found."); 
            }
        }
        else
        {
           println("This device does not support MIDI."); 
        }
 }
 
 /*
   This will be called when a new device is plugged in.
   It will open the new device automatically.
 */
 private void openNewMidiDevice(MidiManager m, MidiDeviceInfo info, MidiReceiver midi) {
   
            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        MidiOutputPort outputPort = device.openOutputPort(0);
                        outputPort.connect(midi);
                    }
                }
              }, new Handler(Looper.getMainLooper()) );  
   
 }
 
 //This needs to be called at a regular interval.  See the runAlgorithm() method in AndroidMIDI.
    public void processMidiEvents() throws IOException {
        long now = System.nanoTime();
        MidiEventScheduler.MidiEvent event = (MidiEventScheduler.MidiEvent) mEventScheduler.getNextEvent(now);
        while (event != null) {
            mFramer.send(event.data, 0, event.count, event.getTimestamp());
            mEventScheduler.addEventToPool(event);
            event = (MidiEventScheduler.MidiEvent) mEventScheduler.getNextEvent(now);
        }
    }
    
  
    //Call this when your sketch is stopped or closed.
    public void stop() {
      mEventScheduler = null;      
    }
    
   public void noteOff(int channel, int noteIndex, int velocity) {
       noteOn(channel, noteIndex, velocity);
    }

    public void allNotesOff() {
      
    }
    
    public void noteOn(int channel, int noteIndex, int vel) {
              
                midiString = "MIDI " + channel + " | " + noteIndex + " | " + vel;  
                if(printData) println(midiString);
       
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

    public void pitchBend(int channel, int bend) {
        double semitones = (mBendRange * (bend - 0x2000)) / 0x2000;
        mFrequencyScaler = (float) Math.pow(2.0, semitones / 12.0);
        midiPitchBendString = "PITCH: " + mFrequencyScaler;
        if(printData) println(midiPitchBendString);
    }
    
    public void controlChange(int channel, int cc, int value) {
       midiCCString = "MIDI " + channel + " | " + cc + " | " + value;
      if(printData) println(midiCCString);
      if(cc == 1)
        controlChange = value;
    }
    
    public void aftertouch(int channel, int noteIndex, int value) {
      midiAftertouchString = "AFTERTOUCH " + channel + " | " + noteIndex + " | " + value;
      aftertouch = value;
      if(printData) println(midiAftertouchString);
    }
    
    /*
    * Public getters, read only
    */
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
