
/*
Since a lot of audio people like to use relative paths this is a helper
method to help with dealing with file names.

It should work on Windows/MacOS/Linux on standard file patterns like:
~/Documents/Audio/Test.wav
../../Test.wav (relative to application, so if using a sketch 
it will be relative to the Processing application)
OR
./Test.wav, Test.wav

Test it before using it in your code.

Thanks to Lisa Tolentino for helping with this code.

*/
String path = "~/Desktop/Test.wav";

 void setup() {
   
   size(640, 360);
   background(255);
   
}

void draw() {
  
  background(255);
  fill(50);
  text(getPath(path), 10, 10, 400, 200); 
  
}
 
 /*
   This method will take a path like ~/Desktop/Test.wav and convert it
   to the correct format for the operating system.
   Windows: C:\\Users\\&&&\\Desktop\\Test.wav
   MacOS/Linux: /Users/&&&/Desktop/Test.wav || /home/&&&/Desktop/Test.wav
   */
   public String getPath(String path) {
     
     String os = System.getProperty( "os.name" ).toLowerCase();
    // Check if Windows.
    if( os.indexOf( "win" ) >= 0 )
    {
     
      if(path.charAt(0) == '~')
      {
         String[] p = splitTokens(path, "~");
         //add home path and format for Windows e.g. \ vs /
         path = System.getProperty("user.home") + p[0].replace("/", "\\");
      }
         
      /*
        This will validate ../../Test.wav syntax.  This is relative to 
        the Processing application, haven't checked how this works with
        an sketch built as an app.
      */
     
      if(path.charAt(0) == '.' && path.charAt(1) == '.')
      {
       String userDir = System.getProperty("user.dir");
       String pt = path.replace("/" , "\\");
      
       String[] str = splitTokens(userDir, "\\");
       String[] p = splitTokens(pt, "\\");
       int newLength = str.length - (p.length - 1);
       String newPath = "";
       if(newLength >=0)
       {
          for(int i = 0; i < newLength; i++)
          {
            newPath += str[i] + "\\" ;
          }
          newPath += p[p.length-1];
       }
       else
       {
        println("Invalid path"); 
       }
       path = newPath;
      }
      
      /*
        This deals with ./Test.wav or .\\Test.wav, it is still relative to 
        the Processing application (not the sketch).
      */
       if(path.charAt(0) == '.' && path.charAt(1) == '/' || path.charAt(1) == '\\')
      {
         String pt = path.replace("\\", "/");
         String[] str = splitTokens(path, "./"); 
         String newPath = System.getProperty("user.dir") + "\\" + str[0] + "." + str[1];
         path = newPath;
      }
      /*
        Otherwise we assume at this point it's just a file name
        so: Test.wav which is relative to the Processing application.
      */
      else if(path.charAt(0) != 'C' && path.charAt(1) != ':') 
      {
        //Otherwise you don't have and ../ or ./ so it's just a file name
         path = System.getProperty("user.dir") + "\\" + path;  
      }
     
      
    }
    else //We're Mac or Linux, have not tested yet.
    {
     // /Users/&&&/Desktop or /home/&&&/Desktop
     if(path.charAt(0) == '~')
      {
         String[] p = splitTokens(path, "~");
         path = System.getProperty("user.home") + p[0];
      }
      
      if(path.charAt(0) == '.' && path.charAt(1) == '.')
      {
       String userDir = System.getProperty("user.dir");
       String[] str = splitTokens(userDir, "/");
       String[] p = splitTokens(path, "/");
       
       int newLength = str.length - (p.length - 1);
       String newPath = "";
       if(newLength >=0)
       {
          for(int i = 0; i < newLength; i++)
          {
            newPath += str[i] + "/" ;
          }
          newPath += p[p.length-1];
       }
       else
       {
        println("Invalid path"); 
       }
       path = newPath;
      }
      
      if(path.charAt(0) == '.' && path.charAt(1) == '/')
      {
         
         String[] str = splitTokens(path, "./"); 
         String newPath = System.getProperty("user.dir") + "/" + str[0] + "." + str[1];
         path = newPath;
      }
      else
      {
        //Otherwise you don't have and ../ or ./ so it's just a file name
         path = System.getProperty("user.dir") + "/" + path; 
      }
    }
     
     return path;
   }
