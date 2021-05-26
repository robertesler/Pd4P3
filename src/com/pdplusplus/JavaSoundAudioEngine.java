package com.pdplusplus;

import java.util.ArrayList;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;
import javax.sound.sampled.TargetDataLine;
import javax.sound.sampled.Mixer;
import javax.sound.sampled.Line;
import javax.sound.sampled.DataLine;


/*
 * This is a audio engine, similar to the Pd class that writes/reads audio to and from the 
 * hardware.  
 * 
 * It is a bit slow in my testing, so I've stuck with jPortAudio.  A lot of this code was adapted from
 * Phil Burk's Jsyn library.  
 * 
 *  @author Robert Esler
 * */

public class JavaSoundAudioEngine extends PdMaster implements Runnable {

	private static AudioFormat audioFormat;
	protected static PdAlgorithm pd;
	private int channels = 2;
	private int bitDepth = 16;
	boolean USE_BIG_ENDIAN = false;
	static private SourceDataLine output;
	static private TargetDataLine input;
	static private int defaultInputDeviceID = -1;
	static private int defaultOutputDeviceID = -1;
	private ArrayList<DeviceInfo> deviceRecords = new ArrayList<DeviceInfo>();
	private static boolean play = true;
	static Thread scheduler;
	
	
	//This bit here is to make sure we only create one instance of this class
	private static JavaSoundAudioEngine singleton = new JavaSoundAudioEngine();
			
	public static JavaSoundAudioEngine getInstance(PdAlgorithm pda) {
			pd = pda;
			scheduler = new Thread(singleton);
			scheduler.setName("pd-scheduler");
			return singleton;
	}
			
	private JavaSoundAudioEngine () {
	
		audioFormat = new AudioFormat(this.getSampleRate(), this.getBitDepth(), this.getChannels(), true, USE_BIG_ENDIAN);
		Line.Info[] lines;
		
		//Get default device
		Mixer.Info[] mixers = AudioSystem.getMixerInfo();
        for (int i = 0; i < mixers.length; i++) {
            DeviceInfo deviceInfo = new DeviceInfo();

            deviceInfo.name = mixers[i].getName();
            Mixer mixer = AudioSystem.getMixer(mixers[i]);

            lines = mixer.getTargetLineInfo();
            deviceInfo.maxInputs = scanMaxChannels(lines);
            // Remember first device that supports input.
            if ((defaultInputDeviceID < 0) && (deviceInfo.maxInputs > 0)) {
                defaultInputDeviceID = i;
                System.out.println("Input Device: " + deviceInfo.name);
            }
            
            
            lines = mixer.getSourceLineInfo();
            deviceInfo.maxOutputs = scanMaxChannels(lines);
            // Remember first device that supports output.
            if ((defaultOutputDeviceID < 0) && (deviceInfo.maxOutputs > 0)) {
                defaultOutputDeviceID = i;
                System.out.println("Output Device: " + deviceInfo.name);
            }

            deviceRecords.add(deviceInfo);
        }
        
        
       DataLine.Info infoOutput = new DataLine.Info(SourceDataLine.class, audioFormat);
        
       Mixer outputMixer = AudioSystem.getMixer(mixers[defaultOutputDeviceID]);
       Line outputLine;
        
        //Get our output stream 
       try {
        outputLine = outputMixer.getLine(infoOutput);
       } catch (Exception e) {
           e.printStackTrace();
           outputLine = null;
       }
       output = (SourceDataLine)outputLine;
       
       
      DataLine.Info infoInput = new DataLine.Info(TargetDataLine.class, audioFormat);
      Mixer inputMixer = AudioSystem.getMixer(mixers[defaultInputDeviceID]);
      Line inputLine;
       
       
       //Get our input stream
      try {
       inputLine = inputMixer.getLine(infoInput);
      } catch (Exception e) {
          e.printStackTrace();
          inputLine = null;
      }
       input = (TargetDataLine)inputLine;
}
	
	 static class DeviceInfo {
         String name;
         int maxInputs;
         int maxOutputs;

         @Override
         public String toString() {
             return "AudioDevice: " + name + ", max in = " + maxInputs + ", max out = " + maxOutputs;
         }
    }
        
    private int scanMaxChannels(DataLine.Info info) {
         int maxChannels = 0;
         for (AudioFormat format : info.getFormats()) {
               int numChannels = format.getChannels();
                if (numChannels > maxChannels) {
                    maxChannels = numChannels;
                }
           }
           return maxChannels;
    }
        
    private int scanMaxChannels(Line.Info[] lines) {
         int maxChannels = 0;
         for (Line.Info line : lines) {
             if (line instanceof DataLine.Info) {
                 int numChannels = scanMaxChannels(((DataLine.Info) line));
                		 if (numChannels > maxChannels) {
                        maxChannels = numChannels;
                 }
             }
         }
         return maxChannels;
    }

	
	private static void writeData(int framesPerBuffer, int channels, int bitDepth) throws InterruptedException {
		
		AudioInputStream str = new AudioInputStream(input);
		byte[] inputByteBuffer = new byte[framesPerBuffer * channels * bitDepth/8];
		float[] inputDoubleBuffer = new float[framesPerBuffer * channels];
		
		byte[] outputByteBuffer = new byte[framesPerBuffer * channels * bitDepth/8];
		float[] outputDoubleBuffer = new float[framesPerBuffer * channels];
		
		//Maybe use this later
		//int frameSize = channels * (bitDepth/8); 
		
		while(play)
		{
			
			//First Read from the input buffer
           try {  
        	   str.read(inputByteBuffer, 0, inputByteBuffer.length);
           }
           catch(Exception e) {
        	   System.out.println("Pd read exception: " + e);
           }
            // Convert BigEndian bytes to float samples, code from JSyn, Phil Burk
            int bi = 0;
            int j = 0;
            for (int i = 0; i < framesPerBuffer; i++) {
            	
            	/*
            	 * Right now this is hand wrapped for 2 channels, 16-bit
            	 */
            	
            	
            	//Left Channel
                int sampleL = inputByteBuffer[bi++] & 0x00FF; // little end
                sampleL = sampleL + (inputByteBuffer[bi++] << 8); // big end
                inputDoubleBuffer[j++] = sampleL * (1.0f / 32767.0f);
               
              //Right Channel
                int sampleR = inputByteBuffer[bi++] & 0x00FF; // little end
                sampleR = sampleR + (inputByteBuffer[bi++] << 8); // big end
                inputDoubleBuffer[j++] = sampleR * (1.0f / 32767.0f);
               
            }
			//System.out.println("JSAE: Starting audio block.");
			
			//Let's get our audio block, in doubles, from pd.algorithm(), put in the outputDoubleBuffer[]
            int k = 0;
            for(int i = 0; i < framesPerBuffer; i++)
            {
            	int indexL = k++;
            	int indexR = k++;
            	
            	pd.runAlgorithm((double)inputDoubleBuffer[indexL], (double)inputDoubleBuffer[indexR]);
            	
            	outputDoubleBuffer[indexL] = (float)PdAlgorithm.outputL;
            	outputDoubleBuffer[indexR] =(float) PdAlgorithm.outputR;
            }

            //Now let's write our audio block to the output stream
            
            // Convert float samples to LittleEndian bytes., a la JSyn/Phil Burk
            int byteIndex = 0;
            int l = 0;
            for (int i = 0; i < framesPerBuffer; i++) {
               /* Offset before casting so that we can avoid using floor().
                * Also round by adding 0.5 so that very small signals go to zero.
            	*
            	* Right now this is hand unwrapped for 2 channels, 16-bit
            	*/
            	
            	//Left Channel
                double left = (32767.0 * outputDoubleBuffer[l++]) + 32768.5;
                int sampleL = ((int) left) - 32768;
                if (sampleL > Short.MAX_VALUE) {
                    sampleL = Short.MAX_VALUE;
                } else if (sampleL < Short.MIN_VALUE) {
                    sampleL = Short.MIN_VALUE;
                }
                outputByteBuffer[byteIndex++] = (byte) sampleL; // little end
                outputByteBuffer[byteIndex++] = (byte) (sampleL >> 8); // big end
                
              //Right Channel
                double right = (32767.0 * outputDoubleBuffer[l++]) + 32768.5;
                int sampleR = ((int) right) - 32768;
                if (sampleR > Short.MAX_VALUE) {
                    sampleR = Short.MAX_VALUE;
                } else if (sampleR < Short.MIN_VALUE) {
                    sampleR = Short.MIN_VALUE;
                }
                outputByteBuffer[byteIndex++] = (byte) sampleL; // little end
                outputByteBuffer[byteIndex++] = (byte) (sampleL >> 8); // big end
            }

            output.write(outputByteBuffer, 0, byteIndex);
			
		}
	}
	
	public void run() {
		try {
			play = true;
			int framesPerBuffer = pd.getBlockSize();
			//int framesPerBuffer = 8;
			input.open(audioFormat);
			input.start();
			output.open(audioFormat);
			output.start();
			
			writeData(framesPerBuffer, this.getChannels(), this.getBitDepth());
			
			
		} catch (Exception e) {
            e.printStackTrace();
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
		if(input != null)
		{
			input.stop();
			input.flush();
			input.close();
			input = null;
		} else {
            new RuntimeException("Input: stop attempted when no line created.")
            .printStackTrace();
		}
		
		if(output != null)
		{
			output.stop();
			output.flush();
			output.close();
			output = null;
		}
		else {
            new RuntimeException("Output: stop attempted when no line created.")
                    .printStackTrace();
        }
		pd.free(); //frees memory from C++ side of the lib
		
		System.out.println( "JavaSound test complete." );
	}
	
	public void setChannels(int ch) {
		channels = ch;
	}
	
	public int getChannels() {
		return channels;
	}
	
	public void setBitDepth(int bd) {
		bitDepth = bd;
	}
	
	public int getBitDepth() {
		return bitDepth;
	}
		
}
