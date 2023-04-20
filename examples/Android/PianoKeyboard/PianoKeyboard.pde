int numOfOctaves = 3;
int numOfKeysInOctave = 7;
int numOfKeys = (numOfKeysInOctave * numOfOctaves)+1;
float keyWidth;
float keyHeight;
float blackKeyHeight;
float blackKeyWidth;

void setup() {
  size(640, 360);
  keyWidth = width/numOfKeys;
  keyHeight = height/2;
  blackKeyHeight = keyHeight *.6;
  blackKeyWidth = keyWidth * .6;
  println( height - blackKeyHeight);
}



void draw() {
  background(100);
  fill(255);
  int i = isKeyPressed(numOfKeys);
  drawKeyboard(numOfKeys, i);
 
  String s = "X: " + mouseX + "Y: " + mouseY;
  textSize(24);
  fill(0);
  text(s, mouseX, mouseY);
  

}

void drawKeyboard(int n, int kn) {
    
    //draw white keys
    for(int i = 0; i < n; i++)
    {
      if(mousePressed == true && i == kn) 
        fill(235);
      else 
        fill(255);
      rect(i*keyWidth, height-keyHeight, keyWidth, keyHeight, 0, 0, 10, 10);
    }
    
    //draw black keys
    for(int i = 0; i < n; i++)
    { 
      int k = (i/numOfKeysInOctave) * numOfKeysInOctave;
      //skip every 3rd and 6th key, plus the very last one
      if((i-k)-2 == 0 || (i-k)-6 == 0 || i == n-1)
        continue;
      fill(0);
      rect((i*keyWidth)+ keyWidth/1.5, height-keyHeight, blackKeyWidth, blackKeyHeight, 0, 0, 10, 10);
    }
}

int isKeyPressed(int n) {
  int keyNum = -1;
  
  for(int i = 0; i < n; i++)
  {
      if(mousePressed == true)
      {
        //First check if we are focused on the keyboard
        if(mouseY > keyHeight)
        {
          //if we are below the black keys, then check which white key
          if(mouseY > height - blackKeyHeight)
          {
             if(mouseX > i*keyWidth && mouseX < (i*keyWidth) + keyWidth)
             {
                keyNum = i;
             }
          }
          //Then we check if we are on a white or black key
          else
          {
            //Still working on tis, we will get the color of the key, then compare to X coords
              int c = get(mouseX, mouseY);
              println(c);
          }
        }
      }
    
  }
  
  return keyNum;
  
}
