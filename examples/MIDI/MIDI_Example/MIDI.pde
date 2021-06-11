import java.io.IOException;
import javax.sound.midi.*;


/*
This class will mimic the Pure Data midi object [notein]
 */
class MIDI implements Receiver {

  Transmitter transmitter;
  MidiDevice keyboard = null;
  MidiDevice.Info[] devices = MidiSystem.getMidiDeviceInfo();
  byte[] theMessage = new byte[4];


  @Override
    public void close() {
      println("Closed MIDI");
  }

  @Override
    public void send(MidiMessage m, long timeStamp) {
      theMessage = m.getMessage();
    
  }

  //uses default channel
  public Notes noteIn() {
    Notes notes = new Notes();
    
    int statusByte = theMessage[0];
    int midiCommand = statusByte & 0xF0;
    int channel = statusByte & 0x0F;

    //Note on
    if (midiCommand == 0x90)
    {
      notes.note = theMessage[1];
      notes.velocity = theMessage[2];
      notes.channel = channel;
    }

    //Note off
    if (midiCommand == 0x80)
    {
      notes.note = theMessage[1];
      notes.velocity = theMessage[2];
      notes.channel = channel;
    }
    

    return notes;
  }

  //if you want to set the channel
  public Notes noteIn(int channel) {
    Notes notes = new Notes();

    int statusByte = theMessage[0];
    int midiCommand = statusByte & 0xF0;


    //Note on
    if (midiCommand == 0x90)
    {
      notes.note = theMessage[1];
      notes.velocity = theMessage[2];
      notes.channel = channel;
    }

    //Note off
    if (midiCommand == 0x80)
    {
      notes.note = theMessage[1];
      notes.velocity = theMessage[2];
      notes.channel = channel;
    }

    return notes;
  }

  public void printDevices() {

    for (MidiDevice.Info d : devices)
    {
      println("Device: " + d.getName() + " | " + d.getDescription()); 

      try {
        MidiDevice myDevice = MidiSystem.getMidiDevice(d);
        //check if device is open
        println("Device: " + d.getName() + " is open? " + myDevice.isOpen());
      }
      catch(MidiUnavailableException e) {
        e.printStackTrace();
      }
    }
  }

  public MidiDevice setKeyboard(String name) {
    MidiDevice keyboard = null;
    MidiDevice.Info[] devices = MidiSystem.getMidiDeviceInfo();

    for (MidiDevice.Info d : devices)
    { 
      try {
        MidiDevice myDevice = MidiSystem.getMidiDevice(d);

        if (myDevice.getMaxTransmitters() != 0)
        {
          if ((name == null) || (d.getName().toLowerCase().contains(name.toLowerCase())))
          {
            keyboard = myDevice;
            println("Device: " + d.getName());
            break;
          }
        }
      }
      catch(MidiUnavailableException e) {
        e.printStackTrace();
      }
    }
    return keyboard;
  }

  public int setUpMIDI(String device) throws MidiUnavailableException, IOException, InterruptedException {

    MidiDevice k = setKeyboard(device);
    int status = -1;
    
    if (k != null)
    {
      k.open();
      transmitter = k.getTransmitter();
      transmitter.setReceiver(this);
      status = 1;
    } else
    {
      println("Keyboard was not found!");
      status = 0;
    }

    return status;
  }
}
