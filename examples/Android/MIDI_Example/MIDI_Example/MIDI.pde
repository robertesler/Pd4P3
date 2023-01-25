import android.content.Context;
import android.content.pm.PackageManager;
import android.media.midi.MidiDevice;
import android.media.midi.MidiDeviceInfo;
import android.media.midi.MidiManager;
import android.media.midi.MidiOutputPort;
import android.media.midi.MidiReceiver;
import android.os.Bundle;

import android.os.Handler;
import android.os.Looper;
    
class MIDI {
   
   private MyReceiver receiver;
   private boolean printData = true;
   int note = 0;
   int velocity = 0;
   int channel = 0;
   
   class MyReceiver extends MidiReceiver {

        MyReceiver() {
            println("MIDI", "Hello, I do exist.");

        }

        public void onSend(byte[] data, int offset,
                           int count, long timestamp) throws IOException {
            
          int currentByte = data[offset];
          int midiCommand = currentByte & 0xFF;

          if(printData)
          {
               //Note Off
            if(midiCommand >= 0x80 && midiCommand <= 0x8F)
            {
                println("MIDI", "Note Off: " + (midiCommand - 127) + " | " + data[offset+1] + " | " + data[offset+2]);

            }

            //Note On
            if(midiCommand >= 0x90 && midiCommand <= 0x9F)
            {
                println("MIDI", "Note On: " + (midiCommand - 143) + " | " + data[offset+1] + " | " + data[offset+2]);
                channel = midiCommand - 143;
                note = data[offset+1];
                velocity = data[offset+2];
            }

            //Polyphonic Aftertouch
            if(midiCommand >= 0xA0 && midiCommand <= 0xAF)
            {
                println("MIDI", "Aftertouch: " + (midiCommand - 159) + " | " + data[offset+1] + " | " + data[offset+2]);

            }

            //Control Change
            if(midiCommand >= 0xB0 && midiCommand <= 0xBF)
            {
                println("MIDI", "CC: " + (midiCommand - 175) + " | " + data[offset+1] + " | " + data[offset+2]);

            }

            //Program Change
            if(midiCommand >= 0xC0 && midiCommand <= 0xCF)
            {
                println("MIDI", "Program Change: " + (midiCommand - 191) + " | " + data[offset+1] + " | " + data[offset+2]);

            }

            //Channel Aftertouch
            if(midiCommand >= 0xD0 && midiCommand <= 0xDF)
            {
                println("MIDI", "Ch Aftertouch: " + (midiCommand - 207) + " | " + data[offset+1] + " | " + data[offset+2]);

            }

            //Pitch Bend
            if(midiCommand >= 0xE0 && midiCommand <= 0xEF)
            {
                println("MIDI", "Pitch Bend: " + (midiCommand - 223) + " | " + data[offset+1] + " | " + data[offset+2]);

            }
            
          }//end if
           
        }//end onSend
    }//end class MyReceiver
    
   public void startMIDI(Context context) {
        
        receiver = new MyReceiver();
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

            m.openDevice(info, new MidiManager.OnDeviceOpenedListener() {
                @Override
                public void onDeviceOpened(MidiDevice device) {
                    if (device == null) {
                        println("MIDI", "could not open device: " + device);
                    } else {
                        println("MIDI", "Opening: " + device.toString());
                        MidiOutputPort outputPort = device.openOutputPort(0);
                        outputPort.connect(receiver);

                    }
                }
            }, new Handler(Looper.getMainLooper()) );
        }

    }
   
 }
