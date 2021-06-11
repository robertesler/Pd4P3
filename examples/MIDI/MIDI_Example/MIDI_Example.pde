import com.pdplusplus.*;

//declare Pd and create new class that inherits PdAlgorithm
Pd pd;
MyMusic music;

void setup() {
  size(640, 360);
  background(255);


  music = new MyMusic();
  music.startMidi();
  pd = Pd.getInstance(music);

  //start the Pd engine thread
  pd.start();
}

void draw() {
}

public void dispose() {
  //stop Pd engine
  pd.stop();
  println("Pd4P3 audio engine stopped.");
  super.dispose();
}

/*
   This example demonstrates how to create a monophonic synth with a MIDI keyboard
 */
class MyMusic extends PdAlgorithm {

  Oscillator osc1 = new Oscillator();
  Oscillator osc2 = new Oscillator();
  Oscillator osc3 = new Oscillator();
  Line line = new Line();
  MIDI midi = new MIDI();
  Notes notes = new Notes();
  //This is my MIDI keyboard, change it to match yours.  use MIDI.printDevices();
  String midiDevice = "Oxygen 49";
  boolean bang = false;
  double amp = 0;
  double env = 0;
  double attack = 10;
  double release = 90;

  //All DSP code goes here
  void runAlgorithm(double in1, double in2) {
    
    notes = midi.noteIn();
    double freq = this.mtof(notes.note);
    amp = (double)notes.velocity/127.0f;
    amp *= amp;//amp^2
    
    //note off
    if(notes.velocity == 0)
    {
     setBang(false); 
    }
    else
    {
     setBang(true); 
    }

    outputL = outputR = ( osc1.perform(freq)*.5 +
                          osc2.perform(freq * 2)*.3 + 
                          osc3.perform(freq * 4)*.2  ) * env;
    
     if(getBang())
     {
     env = line.perform(amp, attack);  
     }
     else
     {
      env = line.perform(amp, release); 
     }
     
     
  }

//call this in the setup() function
  public void startMidi() {
    try 
    {
      midi.setUpMIDI(midiDevice);
    }
    catch(MidiUnavailableException e) {
      e.printStackTrace();
    }
    catch (IOException e) {
      e.printStackTrace();
    } 
    catch (InterruptedException e) {
      e.printStackTrace();
    }
  }
  
  private void setBang(boolean b) {
     bang = b;
   }
   
  private boolean getBang() { 
     return bang;
   }
   

  //Free all objects created from Pd4P3 lib
  void free() {
    Oscillator.free(osc1);
    Oscillator.free(osc2);
    Oscillator.free(osc3);
    Line.free(line);
  }
  
}
