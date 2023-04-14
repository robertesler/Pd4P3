import android.content.Context;
import android.content.pm.PackageManager;
import android.media.midi.*;
import android.os.Bundle;

import android.os.Handler;
import android.os.Looper;
    
class MIDI extends MidiReceiver {
   
   private MyReceiver receiver;
   private MidiEventScheduler mEventScheduler;
   private MidiConstants mConstants = new MidiConstants();
   private MidiFramer mFramer;
   private boolean printData = true;
   int note = 0;
   int velocity = 0;
   int channel = 0;
   private float mFrequencyScaler = 1.0f;
   private float mBendRange = 2.0f; // semitones
   private int mProgram;
   private int mMidiByteCount;
   
    private float[] mBuffer = null;
   
    int max = 8;
    int [] notes = new int[max];
    int [] vels = new int[max];
    int [] voices = new int[max];
    
    int controlChange = 0;
   
    double numOfVoices = 0;
   
    Poly poly = new Poly(max);
   PolyBundle [] pb = new PolyBundle[max];
   
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

        MyReceiver() {
            println("MIDI", "Hello, I do exist.");

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
            default:
                break;
            }
        }
           
       
    }//end class MyReceiver
    
 public void start(Context context, MidiReceiver midi) {
        
        stop();
        mEventScheduler = new MidiEventScheduler();
        
        if (context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_MIDI)) {
            MidiManager m = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
            MidiDeviceInfo[] infos = m.getDevices();
            int myDevice = 0;

            for (int i = 0; i < infos.length; i++) {
                MidiDeviceInfo info = infos[i];

                Bundle properties = info.getProperties();
                String manufacturer = properties
                        .getString(MidiDeviceInfo.PROPERTY_MANUFACTURER);
                String product = properties
                        .getString(MidiDeviceInfo.PROPERTY_PRODUCT);
                String name = properties
                        .getString(MidiDeviceInfo.PROPERTY_NAME);

                println("MIDI", "ID: " + i + " | " + " Output Ports: " + info.getOutputPortCount() + " Manufacturer: " + manufacturer
                        + " Product: " + product + " Name: " + name);

                if (info.getOutputPortCount() > 1) {
                    myDevice = i;
                }
            }

            MidiDeviceInfo info = infos[myDevice];
            int finalMyDevice = myDevice;//use this sometime later maybe? 
            println("My MIDI Device: " + finalMyDevice);
            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        MidiOutputPort outputPort = device.openOutputPort(finalMyDevice);
                        outputPort.connect(midi);

                    }
                }
            }, new Handler(Looper.getMainLooper()) );
        }

    }//end startMIDI
 
 
    public void processMidiEvents() throws IOException {
        long now = System.nanoTime(); // TODO use audio presentation time
        MidiEventScheduler.MidiEvent event = (MidiEventScheduler.MidiEvent) mEventScheduler.getNextEvent(now);
        while (event != null) {
            mFramer.send(event.data, 0, event.count, event.getTimestamp());
            mEventScheduler.addEventToPool(event);
            event = (MidiEventScheduler.MidiEvent) mEventScheduler.getNextEvent(now);
        }
    }
    
    
 

    /*
       Call this when your sketch is stopped or closed.
     */
    public void stop() {
      mEventScheduler = null;      
    }
    
   public void noteOff(int channel, int noteIndex, int velocity) {
       
    }

    public void allNotesOff() {
      
    }
    
    public void noteOn(int channel, int noteIndex, int vel) {
       println("MIDI", channel + " | " + noteIndex + " | " + vel);
       
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
        println("PITCH", mFrequencyScaler);
    }
    
    public void controlChange(int channel, int cc, int value) {
       println("MIDI", channel + " | " + cc + " | " + value);
      if(cc == 1)
        controlChange = value;
    }
    
    public double getPitchBend() {
     
      return mFrequencyScaler;
    }
   
 }
