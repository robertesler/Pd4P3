int numOfOctaves = 2;
int oct = 4;//middle C
String [] white = {"C", "D", "E", "F", "G", "A", "B"};
String [] black = {"C#", "D#", "F#", "G#", "A#"};
int numOfKeys = (numOfOctaves * 12) + 1;
int numOfWhiteKeys = (numOfOctaves * 7) + 1;
int numOfBlackKeys = numOfOctaves * 5;
float keyWidth;
float keyHeight;
float blackKeyHeight;
float blackKeyWidth;
Key [] whiteKeys = new Key[numOfWhiteKeys];
Key [] blackKeys = new Key[numOfBlackKeys];

void setup() {
  //size(640, 360);
  fullScreen();
  orientation(LANDSCAPE);
  //noStroke();
  fill(0); 

  keyWidth = width/numOfWhiteKeys;
  keyHeight = height/2;
  blackKeyHeight = keyHeight *.6;
  blackKeyWidth = keyWidth * .6;
  int t = oct;
  
  for(int i = 0; i < numOfWhiteKeys; i++)
  {
       whiteKeys[i] = new Key();
       whiteKeys[i].keyWidth = keyWidth;
       whiteKeys[i].keyHeight = keyHeight;
       whiteKeys[i].X = i*keyWidth;
       whiteKeys[i].Y = height - keyHeight;
       int k = i % 7;
       if(k == 0) t++;
       whiteKeys[i].name = white[k]+oct;
       whiteKeys[i].col = 255;
       whiteKeys[i].id = -1;
  }

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
              break;
          case 1:
              blackKeys[i].X = 2*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[1]+t;
              break;
          case 2:
              blackKeys[i].X = 4*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[2]+t;
              break;
          case 3:
              blackKeys[i].X = 5*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[3]+t;
              break;
          case 4:
              blackKeys[i].X = 6*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[4]+t;
              break;
          case 5:
              blackKeys[i].X = 8*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[0]+t++;//increment the octave
              break;
          case 6:
              blackKeys[i].X = 9*keyWidth - blackKeyWidth/2;
               blackKeys[i].name = black[1]+t;
              break;
          case 7:
              blackKeys[i].X = 11*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[2]+t;
              break;
          case 8:
              blackKeys[i].X = 12*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[3]+t;
              break;
          case 9:
              blackKeys[i].X = 13*keyWidth - blackKeyWidth/2;
              blackKeys[i].name = black[4]+t;
              break;
         
       }
       blackKeys[i].Y = height - keyHeight;
       blackKeys[i].col = 0;
       blackKeys[i].id = -1;
  }
 
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
     }
    
    for(int i = 0; i < numOfBlackKeys; i++)
    {
        blackKeys[i].touched = false;
        blackKeys[i].col = 0; 
        blackKeys[i].id = -1;
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
        }
     }
     
     for(int i = 0; i < numOfBlackKeys; i++)
     {
        if(blackKeys[i].id != touches[t].id)
        {
            blackKeys[i].touched = false;
            blackKeys[i].col = 0; 
            blackKeys[i].id = -1;
        }
     }
   }
}

void draw() {
  background(100);
  fill(255);
  
  //We evaluate each touch's location and if it is a white or black key change the color and log it.
   for(int t = 0; t < touches.length; t++)
   {
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
