

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
      
      if(chs > 4)
        chs = 4;
      
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
         println("DEVICE: ", i, d.name, d.hostApi, d.maxOutputChannels, d.maxInputChannels);
      }
      
      // Get the default device and setup the stream parameters.
      int deviceId = PortAudio.getDefaultOutputDevice();
      //int deviceId = 30;
      DeviceInfo deviceInfo = PortAudio.getDeviceInfo( deviceId );
      sampleRate = deviceInfo.defaultSampleRate;
      int inputDeviceId = PortAudio.getDefaultInputDevice();
      //int inputDeviceId = 29;
      DeviceInfo inputDeviceInfo = PortAudio.getDeviceInfo(inputDeviceId);
      
      
      //pass info to Pd++, then all objects inherit this information, set your important stuff here
      this.setSampleRate((long)sampleRate);
      /*
      this.setBlockSize(64);
      this.setFFTWindow(64);
      */
      
      System.out.println( "  deviceId    = " + deviceId );
      System.out.println( "  inputDeviceId   = " + inputDeviceId);
      System.out.println( "  sampleRate  = " + sampleRate );
      System.out.println( "  output device name = " + deviceInfo.name );
      System.out.println( "  input device name = " + inputDeviceInfo.name );

      streamParameters.channelCount = channels;
      streamParameters.device = deviceId;
      streamParameters.suggestedLatency = deviceInfo.defaultLowOutputLatency;
            
      inputStreamParameters.channelCount = channels;
      inputStreamParameters.device = inputDeviceId;
      inputStreamParameters.suggestedLatency = deviceInfo.defaultLowInputLatency;

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
        float in1 = 0;
        float in2 = 0;
        float in3 = 0;
        float in4 = 0;
          
        stream.read(input, framesPerBuffer);
       
        for( int j = 0; j < framesPerBuffer; j++ )
        {
          if(this.channels == 4)
          {
         
            in1 = input[inputIndex++];
            in2 = input[inputIndex++];
            in3 = input[inputIndex++];
            in4 = input[inputIndex++]; 
           
          }
          
          if(this.channels == 2)
          {
             in1 = input[inputIndex++];
             in2 = input[inputIndex++]; 
          }
          
        
          music.runAlgorithm((double)in1, (double)in2, (double)in3, (double)in4);
         
          if(this.channels == 4)
          {
            buffer[index++] = (float)music.output1;
            buffer[index++] = (float)music.output2;
            buffer[index++] = (float)music.output3;
            buffer[index++] = (float)music.output4;
            //println("OUTPUT:", (float)music.output4);
          }
          
          if(this.channels == 2)
          {
            buffer[index++] = (float)music.output1;
            buffer[index++] = (float)music.output2;
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
