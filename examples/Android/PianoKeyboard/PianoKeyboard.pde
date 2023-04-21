int numOfOctaves = 2;
int numOfKeysInOctave = 7;
int numOfKeys = (numOfKeysInOctave * numOfOctaves)+1;
float keyWidth;
float keyHeight;
float blackKeyHeight;
float blackKeyWidth;
boolean blackKey = false;

void setup() {
  size(640, 360);
  keyWidth = width/numOfKeys;
  keyHeight = height/2;
  blackKeyHeight = keyHeight *.6;
  blackKeyWidth = keyWidth * .6;
}



void draw() {
  background(100);
  fill(255);
  int i = isKeyPressed(numOfKeys);
  drawKeyboard(numOfKeys, i);
  String s = "X: " + mouseX + "Y: " + mouseY;
  textSize(24);
  fill(25);
  text(s, mouseX, mouseY);
  

}

void drawKeyboard(int n, int kn) {
    
    //draw white keys
    for(int i = 0; i < n; i++)
    {
      if(mousePressed == true && i == kn && blackKey == false) 
        fill(235);
      else 
        fill(255);
      rect(i*keyWidth, height-keyHeight, keyWidth, keyHeight, 0, 0, 10, 10);
    }
    
    //draw black keys
    for(int i = 0; i < n; i++)
    { 
      //k is our octave constant, every octave will repeat the same skips
      int k = (i/numOfKeysInOctave) * numOfKeysInOctave;
      
      //skip every 3rd and 6th key, plus the very last one
      if((i-k)-2 == 0 || (i-k)-6 == 0 || i == n-1)
        continue;
      
      if(mousePressed == true && i == kn && blackKey == true) 
        fill(85);
      else 
        fill(0);

      rect((i*keyWidth)+ keyWidth/1.5, height-keyHeight, blackKeyWidth, blackKeyHeight, 0, 0, 10, 10);
    }
}

int isKeyPressed(int n) {
  int keyNum = -1;
  
  if(mousePressed == true)
   {
    for(int i = 0; i < n; i++)
    {
        float blackKeyStart = (i*keyWidth) + blackKeyWidth;
        float blackKeyEnd = blackKeyStart + blackKeyWidth *1.1 ;
        
        //println(blackKeyStart, blackKeyEnd);
        //First check if we are focused on the keyboard
        if(mouseY > keyHeight)
        {
          //if we are below the black keys, then check which white key
          if(mouseY > height - (keyHeight - blackKeyHeight))
          {
             if(mouseX > i*keyWidth && mouseX < (i*keyWidth) + keyWidth)
             {
                keyNum = i;
                blackKey = false;
                break;
             }
          }
          //Then we check if we are on a black key
          else if(mouseX > blackKeyStart && mouseX < blackKeyEnd)
          {
              //Known bug: this will also detect a black key on E and B above blackKeyHeight
              keyNum = i;
              blackKey = true; 
              break;
            
          }
          //If not on a black key and above the blackKeyHeight, we are a white key
          else if(mouseX > i*keyWidth && mouseX < (i*keyWidth) + keyWidth + (blackKeyWidth * .4))
          {
            //ANother bug: this works but the edges of F and C are a little off.  
              keyNum = i;
              blackKey = false;  
              break;
          
          }
        }
    }
     
}
  
  return keyNum;
  
}
