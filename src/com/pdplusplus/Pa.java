package com.pdplusplus;
import com.portaudio.*;

/*
 * PortAudio support
 * This will start and stop the audio process
 * Includes the process block for PortAudio
 * 
 *  @author Robert Esler
 * */

public class Pa extends PdMaster implements Runnable {

		static StreamParameters streamParameters = new StreamParameters();
		static StreamParameters inputStreamParameters = new StreamParameters();
		static double sampleRate;
		static BlockingStream stream;
		private static boolean play = true;
		static PdAlgorithm pd;
		static Thread scheduler;
		static long time = 0;
		static long startTime = 0;
		static boolean test = false;
		
		//This bit here is to make sure we only create one instance of this class
		private static Pa singleton = new Pa();
		
		public static Pa getInstance(PdAlgorithm pda) {
			pd = pda;
			scheduler = new Thread(singleton);
			scheduler.setName("pd-scheduler");
			return singleton;
		}
	
		private Pa () {
			
			//Initialize Portaudio
			PortAudio.initialize();
			// Get the default device and setup the stream parameters.
			int deviceId = PortAudio.getDefaultOutputDevice();
			DeviceInfo deviceInfo = PortAudio.getDeviceInfo( deviceId );
			sampleRate = deviceInfo.defaultSampleRate;
			int inputDeviceId = PortAudio.getDefaultInputDevice();
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
			System.out.println( "  output device chs = " + deviceInfo.maxOutputChannels );
			System.out.println( "  input device name = " + inputDeviceInfo.name );
			System.out.println( "  input device chs = " + inputDeviceInfo.maxInputChannels );
			
			streamParameters.channelCount = deviceInfo.maxOutputChannels;
			streamParameters.device = deviceId;
			streamParameters.suggestedLatency = deviceInfo.defaultLowOutputLatency;
						
			inputStreamParameters.channelCount = inputDeviceInfo.maxInputChannels;
			inputStreamParameters.device = inputDeviceId;
			inputStreamParameters.suggestedLatency = deviceInfo.defaultLowInputLatency;

			System.out.println( "  suggestedLatency = "
					+ streamParameters.suggestedLatency );
			
		}
		
		//Method to write data to the ring buffer
		private static void writeData( BlockingStream stream, int framesPerBuffer, int channels)
		{
			float[] buffer = new float[framesPerBuffer * channels];
			float[] input = new float[framesPerBuffer * channels];	
			
			while( play )
			{
				int index = 0;
				int inputIndex = 0;
				
				stream.read(input, framesPerBuffer);
				/*
				 * This is the process block, it sends the input stream to the PdAlgorithm.runAlgorithm() method
				 * If you wanted more than 2 channels of input or output you would have to update this method and
				 * PdAlgorithm to reflect the # of channels.
				 * */
				for( int j = 0; j < framesPerBuffer; j++ )
				{
					float in1 = input[inputIndex++];
					float in2 = input[inputIndex++];
					
					pd.runAlgorithm((double)in1, (double)in2);
					buffer[index++] = (float)PdAlgorithm.outputL;
					buffer[index++] = (float)PdAlgorithm.outputR;
				}
				stream.write( buffer, framesPerBuffer );
				if(getTest())
				{
					System.out.println("Block time: " + getTime()/1000000);
					test = false;
				}
			}
			
		}
		
		public void setTime() {
			startTime = System.nanoTime();
		}
		
		public static long getTime() {
			return time = System.nanoTime() - startTime;
		}
		
		public void setTest(boolean t) {
			test = t;
		}
		
		public static boolean getTest() {
			return test;
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
				writeData( stream, framesPerBuffer, streamParameters.channelCount );
				
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
			pd.free(); //frees memory from C++ side of the lib
			PortAudio.terminate();//ends PortAudio stream
			System.out.println( "JPortAudio test complete." );
		}
}
