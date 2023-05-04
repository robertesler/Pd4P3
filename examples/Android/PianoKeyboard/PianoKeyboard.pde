import com.pdplusplus.*;

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
int pbTouch = 200;
int vTouch = 245;
Key [] whiteKeys = new Key[numOfWhiteKeys];
Key [] blackKeys = new Key[numOfBlackKeys];

MyMusic music = new MyMusic();
PdAndroid pd = new PdAndroid(music);
MIDI midi = new MIDI();


void setup() {
  //size(640, 360);
  midi.start( this.getContext() );
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

//We have to deallocate memory in the Pd4P3 native lib before we leave. 
 public void onDestroy() {
   super.onDestroy();
   if(pd.isPlaying() == true)
     pd.stop();
   pd.free();
  
}

void draw() {
  background(100);
  fill(255);
  
  //draw our pitch bend rectangle
  fill(pbTouch);
  rect(20, 10, width*.95, (height/4)*.85, 10);
  textSize(128);
  fill(0);
  String s = "Pitch Bend";
  text(s, width/3, height/7.5);
  
  //draw our vibrato rectangle
  fill(vTouch);
  rect(20, height/4, width*.95, (height/4)*.85, 10);
  fill(0);
  String s1 = "Vibrato";
  text(s1, width/3, height/2.5);
  
  //We evaluate each touch's location and if it is a white or black key change the color and log it.
   for(int t = 0; t < touches.length; t++)
   {
        //pitch bend
        if(touches[t].y > 0 && touches[t].y < height/7.5)
        {
          float pitchBend = map(touches[t].x, 0, width, 0, 2);
          midi.setPitchBend(pitchBend);
          pbTouch = 180;
        }
        else
        {
          pbTouch = 200;
        }
        
        if(touches[t].y > height/7.5 && touches[t].y < height/2.5)
        {
          float vibrato = map(touches[t].x, 0, width, 0, 127);
          midi.setVibrato((int)vibrato);
          vTouch = 255;
        }
        else
          vTouch = 245;
        
        
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
