/*
We will audio run on a separate thread.  You shouldn't need to
edit this much.  But if you want change the number of 
channels greater than 8 then look at the function: 
 
 private void writeData( BlockingStream stream, int framesPerBuffer, int channels);

*/

public class PaMulti extends PdMaster implements Runnable {
  
    StreamParameters streamParameters = new StreamParameters();
    StreamParameters inputStreamParameters = new StreamParameters();
    double sampleRate;
    BlockingStream stream;
    private boolean play = true;
    Thread scheduler;
    int channels = 2;
    
    public PaMulti (int chs) {
      
      scheduler = new Thread(this);
      scheduler.setName("pd-scheduler");
      
      if(chs > 8)
        {
          chs = 8;
          println("Max Channels is 8.  Defaulting to 8 channels.");
        }
      
      channels = chs;
      //Initialize Portaudio
      PortAudio.initialize();
      
      int numDevices = PortAudio.getDeviceCount();
      int host = PortAudio.getHostApiCount();
      
      for(int i = 0; i < host; i++)
      {
        HostApiInfo hostApi = PortAudio.getHostApiInfo(i);
        println("HOST: ", i, hostApi.name);
      }
      
      println(PortAudio.hostApiTypeIdToHostApiIndex(3 ));

      for(int i = 0; i < numDevices; i++)
      {
         DeviceInfo d = PortAudio.getDeviceInfo(i);
         println("DEVICE: ", i, d.name, d.hostApi, d.maxInputChannels, d.maxOutputChannels);
      }
      
      // Get the default device and setup the stream parameters.
      int deviceId = PortAudio.getDefaultOutputDevice();
      DeviceInfo deviceInfo = PortAudio.getDeviceInfo( deviceId );
      sampleRate = deviceInfo.defaultSampleRate;
      int inputDeviceId = PortAudio.getDefaultInputDevice();
      DeviceInfo inputDeviceInfo = PortAudio.getDeviceInfo(inputDeviceId);
      
      
      //pass info to Pd++, then all objects inherit this information, set your important stuff here
      this.setSampleRate((long)sampleRate);
      streamParameters.channelCount = channels;
      streamParameters.device = deviceId;
      streamParameters.suggestedLatency = deviceInfo.defaultLowOutputLatency;
            
      inputStreamParameters.channelCount = channels;
      inputStreamParameters.device = inputDeviceId;
      inputStreamParameters.suggestedLatency = deviceInfo.defaultLowInputLatency;
     
      System.out.println( "  output channels   = " +  streamParameters.channelCount);
      System.out.println( "  deviceId    = " + deviceId );
      System.out.println( "  input channels   = " + inputStreamParameters.channelCount);
      System.out.println( "  inputDeviceId   = " + inputDeviceId);
      System.out.println( "  sampleRate  = " + sampleRate );
      System.out.println( "  output device name = " + deviceInfo.name );
      System.out.println( "  input device name = " + inputDeviceInfo.name );

      

      System.out.println( "  suggestedLatency = "
          + streamParameters.suggestedLatency );
      
     
    }
    
    //Method to write data to the ring buffer
    private void writeData( BlockingStream stream, int framesPerBuffer, int channels)
    {
      float[] buffer = new float[framesPerBuffer * channels];
      float[] input = new float[framesPerBuffer * channels];  
      
      while( play )
      {
        int index = 0;
        int inputIndex = 0;
        double [] in = new double[channels];
          
        stream.read(input, framesPerBuffer);
       
        for( int j = 0; j < framesPerBuffer; j++ )
        {
          
          if(this.channels == 8)
          {
            in[0] = input[inputIndex++];
            in[1] = input[inputIndex++];
            in[2] = input[inputIndex++];
            in[3] = input[inputIndex++];
            in[4] = input[inputIndex++];
            in[5] = input[inputIndex++];
            in[6] = input[inputIndex++];
            in[7] = input[inputIndex++];
          }
          
          if(this.channels == 6)
          {
            in[0] = input[inputIndex++];
            in[1] = input[inputIndex++];
            in[2] = input[inputIndex++];
            in[3] = input[inputIndex++];
            in[4] = input[inputIndex++];
            in[5] = input[inputIndex++];
          }
          
          if(this.channels == 4)
          {
         
            in[0] = input[inputIndex++];
            in[1] = input[inputIndex++];
            in[2] = input[inputIndex++];
            in[3] = input[inputIndex++]; 
           
          }
          
          if(this.channels == 2)
          {
             in[0] = input[inputIndex++];
             in[1] = input[inputIndex++]; 
          }
          
        
          music.runAlgorithm(in);
         
          if(this.channels == 8)
          {
            buffer[index++] = (float)music.output[0];
            buffer[index++] = (float)music.output[1];
            buffer[index++] = (float)music.output[2];
            buffer[index++] = (float)music.output[3];
            buffer[index++] = (float)music.output[4];
            buffer[index++] = (float)music.output[5];
            buffer[index++] = (float)music.output[6];
            buffer[index++] = (float)music.output[7];
            
          }
         
          if(this.channels == 6)
          {
            buffer[index++] = (float)music.output[0];
            buffer[index++] = (float)music.output[1];
            buffer[index++] = (float)music.output[2];
            buffer[index++] = (float)music.output[3];
            buffer[index++] = (float)music.output[4];
            buffer[index++] = (float)music.output[5];
            //println("OUTPUT:", (float)music.output4);
          }
         
          if(this.channels == 4)
          {
            buffer[index++] = (float)music.output[0];
            buffer[index++] = (float)music.output[1];
            buffer[index++] = (float)music.output[2];
            buffer[index++] = (float)music.output[3];
            //println("OUTPUT:", (float)music.output4);
          }
          
          if(this.channels == 2)
          {
            buffer[index++] = (float)music.output[0];
            buffer[index++] = (float)music.output[1];
          }
          
          
        }
        stream.write( buffer, framesPerBuffer );
        
      }
      
    }
    
    public void run()
    {
      try {
        play = true;
        int framesPerBuffer = pd.getBlockSize();
        int flags = 0;
        
        // Open a stream for output.
        stream = PortAudio.openStream( inputStreamParameters, streamParameters,
            (int) sampleRate, framesPerBuffer, flags );
        
        stream.start();
        writeData( stream, framesPerBuffer, this.channels);
        
      } catch (Exception e) {
              // Throwing an exception
              System.out.println("Pd Thread Exception caught: " + e);
          }
      
    }
    
    public void start() {
      
      scheduler.setPriority(Thread.MAX_PRIORITY);
      scheduler.start();
    }
    
    //overloaded start() to set thread priority if necessary
    public void start(int priority)
    {
      scheduler.setPriority(priority);
      scheduler.start();
    }
    
    public void stop() {
      play = false;//stops process block
      stream.stop();
      stream.close();
      music.free(); //frees memory from C++ side of the lib
      PortAudio.terminate();//ends PortAudio stream
      System.out.println( "JPortAudio test complete." );
    }
  
}
