import com.pdplusplus.*;

/*
This is an example of how to send MIDI to another
device. Right now there is no way to manually
select the device to open, so the best way to use
this is to open the app first, then plug it 
into a computer.  This should open the computer
as your input device (e.g. the device for MIDI to
be inputted to. You will have to set the device for "MIDI INPUT")
Then in your software select the phone as your MIDI
controller.  This should send Note On data, CC and Pitch Bend.

This sketch will also draw a keyboard synth.  The synth sound is 
the same as the AndroidMIDI sketch.  

*/

int numOfOctaves = 2;
int oct = 4;//middle C
int C = 60;
int velocity = 110;
int [] notes = {C, C+2, C+4, C+5, C+7, C+9, C+11};
int [] sharps = {C+1, C+3, C+6, C+8, C+10};
String [] white = {"C", "D", "E", "F", "G", "A", "B"};
String [] black = {"C#", "D#", "F#", "G#", "A#"};
int numOfKeys = (numOfOctaves * 12) + 1;
int numOfWhiteKeys = (numOfOctaves * 7) + 1;
int numOfBlackKeys = numOfOctaves * 5;
float keyWidth;
float keyHeight;
float blackKeyHeight;
float blackKeyWidth;
color pbTouch = color(150, 188, 222);
color vTouch = color(84, 144, 196);
Key [] whiteKeys = new Key[numOfWhiteKeys];
Key [] blackKeys = new Key[numOfBlackKeys];
int midiToggle = 0;
int midiCounter = 0;
boolean midiSwitch = false;
int debounceTime = 0;
boolean debounce = false;

MyMusic music = new MyMusic();
PdAndroid pd = new PdAndroid(music);
MIDI midi = new MIDI();

void setup() {
  //size(640, 360);
  midi.start( this.getContext(), 0 );
  fullScreen();
  orientation(LANDSCAPE);
  //noStroke();
  fill(0); 

  pd.start();
  new Thread(pd).start();
  
  
  keyWidth = width/numOfWhiteKeys;
  keyHeight = height/2;
  blackKeyHeight = keyHeight *.6;
  blackKeyWidth = keyWidth * .6;
  int t = oct-1;
  int twelve = -12;
  
  for(int i = 0; i < numOfWhiteKeys; i++)
  {
       whiteKeys[i] = new Key();
       whiteKeys[i].keyWidth = keyWidth;
       whiteKeys[i].keyHeight = keyHeight;
       whiteKeys[i].X = i*keyWidth;
       whiteKeys[i].Y = height - keyHeight;
       int k = i % 7;
       if(k == 0)
       {
         t++;
         twelve += 12;
       }
       whiteKeys[i].name = white[k]+t;
       whiteKeys[i].note = notes[k]+ twelve;
       whiteKeys[i].col = 255;
       whiteKeys[i].id = -1;
  }
  
  t = oct;
  twelve = 0;
  for(int i = 0; i < numOfBlackKeys; i++)
  {
       blackKeys[i] = new Key();
       blackKeys[i].keyWidth = blackKeyWidth;
       blackKeys[i].keyHeight = blackKeyHeight;
      
       switch(i)
       {
          case 0:
              blackKeys[i].X = keyWidth - blackKeyWidth/2; 
              blackKeys[i].name = black[0]+t;
              blackKeys[i].note = sharps[0];
              break;
          case 1:
              blackKeys[i].X = 2*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[1]+t;
              blackKeys[i].note = sharps[1];
              break;
          case 2:
              blackKeys[i].X = 4*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[2]+t;
              blackKeys[i].note = sharps[2];
              break;
          case 3:
              blackKeys[i].X = 5*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[3]+t;
              blackKeys[i].note = sharps[3];
              break;
          case 4:
              blackKeys[i].X = 6*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[4]+t;
              blackKeys[i].note = sharps[4];
              break;
          case 5:
              blackKeys[i].X = 8*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[0]+t++;//increment the octave
              blackKeys[i].note = sharps[0]+12;
              break;
          case 6:
              blackKeys[i].X = 9*keyWidth - blackKeyWidth/2;
               blackKeys[i].name = black[1]+t;
               blackKeys[i].note = sharps[1]+12;
              break;
          case 7:
              blackKeys[i].X = 11*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[2]+t;
              blackKeys[i].note = sharps[2]+12;
              break;
          case 8:
              blackKeys[i].X = 12*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[3]+t;
              blackKeys[i].note = sharps[3]+12;
              break;
          case 9:
              blackKeys[i].X = 13*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[4]+t;
              blackKeys[i].note = sharps[4]+12;
              break;
         
       }
       blackKeys[i].Y = height - keyHeight;
       blackKeys[i].col = 0;
       blackKeys[i].id = -1;
      
  }
 
}

void sendNote(int note, int vel) {
   midi.sendNote(note, vel);  
}

void touchStarted() {
  
}

void touchEnded() {
  
  //If we stop touching the keyboard, reset
  if(touches.length == 0)
  {
    for(int i = 0; i < numOfWhiteKeys; i++)
     {
         whiteKeys[i].touched = false;
         whiteKeys[i].col = 255; 
         whiteKeys[i].id = -1;
         sendNote(whiteKeys[i].note, 0);
     }
    
    for(int i = 0; i < numOfBlackKeys; i++)
    {
        blackKeys[i].touched = false;
        blackKeys[i].col = 0; 
        blackKeys[i].id = -1;
        sendNote(blackKeys[i].note, 0);
    }
    midi.setPitchBend(1);
    pbTouch = color(150, 188, 222);
    vTouch = color(84, 144, 196);
    
  }
  
  //If we lost a touch, then find it and reset it
  for(int t = 0; t < touches.length; t++)
   {
     for(int i = 0; i < numOfWhiteKeys; i++)
     {
        if(whiteKeys[i].id != touches[t].id)
        {
            whiteKeys[i].touched = false;
            whiteKeys[i].col = 255; 
            whiteKeys[i].id = -1;
            sendNote(whiteKeys[i].note, 0);
        }
     }
     
     for(int i = 0; i < numOfBlackKeys; i++)
     {
        if(blackKeys[i].id != touches[t].id)
        {
            blackKeys[i].touched = false;
            blackKeys[i].col = 0; 
            blackKeys[i].id = -1;
            sendNote(blackKeys[i].note, 0);
        }
     }
   }
}

boolean debounce(int delay) {
    
  int t = millis();
  int time = t - debounceTime;
  debounceTime = t;
  if(time > delay)
  {
    midiToggle = midiCounter++ % 2;
    return true;
  }
  else
  {
    return false;
  }
  
}

//We have to deallocate memory in the Pd4P3 native lib before we leave. 
 public void onDestroy() {
   super.onDestroy();
   midi.stop();
   if(pd.isPlaying() == true)
     pd.stop();
   pd.free();
  
}

void draw() {
  background(179, 214, 245);
  //fill(255);
  strokeWeight(4);
  //draw our pitch bend rectangle
  fill(pbTouch);
  rect(20, 10, width-40, (height/4)*.85, 10);
  textSize(90);
  fill(0);
  String s = "Pitch Bend";
  text(s, width/3, height/7.5);
  
  //draw our vibrato rectangle
  fill(vTouch);
  rect(20, height/4, width*.75, (height/4)*.85, 10);
  fill(0);
  String s1 = "Vibrato";
  text(s1, width/3, height/2.5);
  
  //draw our MIDI on/off switch
  fill(255);
  rect(width*.77, height/4, width*.18, (height/4)*.85, 10);
  fill(0);
  String s2 = "MIDI ";
  text(s2, width*.82,height/2.5);
  
  if(midiSwitch)
  {
   line(width*.77, height/4,  width*.95, height/2.16);
   line(width*.77, height/2.16, width*.95, height/4);
  }

  
  //We evaluate each touch's location and if it is a white or black key change the color and log it.
   for(int t = 0; t < touches.length; t++)
   {
        //pitch bend
        if(touches[t].y > 0 && touches[t].y < height/4)
        {
          float pitchBend = map(touches[t].x, 10, width-40, 0.89, 1.12);
          midi.setPitchBend(pitchBend);
          pbTouch = color(58, 147, 224);
          float d = (100 + 100 * touches[t].area) * displayDensity;
          fill(0, 255 * touches[t].pressure);
          ellipse(touches[t].x, touches[t].y, d, d);
        }
        else
        {
         // midi.setPitchBend(1);
          pbTouch = color(150, 188, 222);
        }
        //vibrato
        if(touches[t].y > height/4 && touches[t].y < height/2 && touches[t].x < width*.75)
        {
          float vibrato = map(touches[t].x, 10, width*.75, 0, 127);
          midi.setVibrato((int)vibrato);
          vTouch = color(23, 113, 191);
          float d = (100 + 100 * touches[t].area) * displayDensity;
          fill(0, 255 * touches[t].pressure);
          ellipse(touches[t].x, touches[t].y, d, d);
        }
        else
        {
          vTouch = color(84, 144, 196);
        }
        
        //Our MIDI on/off switch
        if(touches[t].y > height/4 && touches[t].y < height/2 && touches[t].x > width*.77)
        {
          debounce = debounce(250);
          if(midiToggle == 1 && debounce)
          {
            midiSwitch = true;
            midi.setUseAsMidiDevice(true);//send MIDI to inputPort
          }
          if(midiToggle == 0 && debounce)
          {
            midiSwitch = false;
            midi.setUseAsMidiDevice(false);//don't send MIDI
          }
         
        }
        
        if(touches[t].y > height/2)
         {
          if(touches[t].y > height/2 + blackKeyHeight)
           {
              for(int i = 0; i < numOfWhiteKeys; i++)
              {
                if(touches[t].x > whiteKeys[i].X  && touches[t].x < whiteKeys[i].X+whiteKeys[i].keyWidth)
                {
                   //we are a white key
                   whiteKeys[i].touched = true;
                   whiteKeys[i].col = 230;
                   whiteKeys[i].id = touches[t].id;
                   sendNote(whiteKeys[i].note, velocity);
                }
              }
           }
         
           if(touches[t].y > height/2 && touches[t].y < height/2 + blackKeyHeight)
           {
           
             for(int i = 0; i < numOfBlackKeys; i++)
             {
               if(touches[t].x > blackKeys[i].X && touches[t].x < blackKeys[i].X+blackKeys[i].keyWidth)
               {
                 //we are a black key
                 blackKeys[i].touched = true;
                 blackKeys[i].col = 70;
                 blackKeys[i].id = touches[t].id;
                 sendNote(blackKeys[i].note, velocity);
               }
             } 
           }
       }    
    
  }
  
  for(int i = 0; i < numOfWhiteKeys; i++)
  {
     fill(whiteKeys[i].col);
     rect(whiteKeys[i].X, whiteKeys[i].Y, whiteKeys[i].keyWidth, whiteKeys[i].keyHeight,  whiteKeys[i].edges[0], 
     whiteKeys[i].edges[1], whiteKeys[i].edges[2], whiteKeys[i].edges[3]);
  }
  
  for(int i = 0; i < numOfBlackKeys; i++)
  {
    fill(blackKeys[i].col);
    rect(blackKeys[i].X, blackKeys[i].Y, blackKeys[i].keyWidth, blackKeys[i].keyHeight,  blackKeys[i].edges[0], 
     blackKeys[i].edges[1], blackKeys[i].edges[2], blackKeys[i].edges[3]);
  }
  
}
