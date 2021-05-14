package com.pdplusplus;
import com.portaudio.*;

/*
 * This is a utility class for Pd++ it will start and stop the audio process
 * Includes the process block for PortAudio
 * */

public class Pd extends PdMaster implements Runnable {

		static StreamParameters streamParameters = new StreamParameters();
		static StreamParameters inputStreamParameters = new StreamParameters();
		static double sampleRate;
		static BlockingStream stream;
		private static boolean play = true;
		static PdAlgorithm pd;
		static Thread scheduler;
		
		//This bit here is to make sure we only create one instance of this class
		private static Pd singleton = new Pd();
		
		public static Pd getInstance(PdAlgorithm pda) {
			pd = pda;
			scheduler = new Thread(singleton);
			scheduler.setName("pd-scheduler");
			return singleton;
		}
	
		private Pd () {
			
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
			this.setBlockSize(64);
			this.setFFTWindow(512);
			
			System.out.println( "  deviceId    = " + deviceId );
			System.out.println( "  inputDeviceId   = " + inputDeviceId);
			System.out.println( "  sampleRate  = " + sampleRate );
			System.out.println( "  output device name = " + deviceInfo.name );
			System.out.println( "  input device name = " + inputDeviceInfo.name );

			streamParameters.channelCount = 2;
			streamParameters.device = deviceId;
			streamParameters.suggestedLatency = deviceInfo.defaultLowOutputLatency;
						
			inputStreamParameters.channelCount = 2;
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
