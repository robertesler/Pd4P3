package com.pdplusplus;

/*
 * This class will write a sound file in chunks to disk. 
 * It will not finish writing until stop() is called.
 * 
 * The class will only support uncompressed file types such as
 * .wav, .aif, .mat, .au or .raw.  Default type is .wav.
 * 
 * You can specify the bit depth by setting the format in the open() 
 * method (see below).  Default is 16-bit, see the formats below for
 * more options.
 * 
 * You can write up to 8-channels, the start() method will take them
 * as an interleaved array, so you would need to handle your audio
 * in an array the size of your channels.
 * 
 * To write to disk you need to use open() with a file path and the name
 * of the file such as: open("C:\\Users\\***\\Desktop\\Test.wav");
 * 
 * Then start(array); would go in your runAlgorithm() method.
 * 
 * Call stop() when you want to close and write the file.
 */

public class WriteSoundFile extends PdMaster {

	
	//types
		 public final long FILE_RAW = 1;
		 public final long FILE_WAV = 2;
		 public final long FILE_SND = 3;
		 public final long FILE_AIF = 4;
		 public final long FILE_MAT = 5;
		
		//formats
		 public final long STK_SINT8   = 0x1;
		 public final long STK_SINT16  = 0x2;
		 public final long STK_SINT24  = 0x4;
		 public final long STK_SINT32  = 0x8;
		 public final long STK_FLOAT32 = 0x10;
		 public final long STK_FLOAT64 = 0x20;
	
	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		private static native void open0(String file, int nChannels, long ptr);
		private static native void open0(String file, int nChannels, long type, long format, long ptr);
		private static native void start0(double[] input, long ptr);
		private static native void stop0(long ptr);
		private static native void print0(long ptr);
		
		//These match the Pd++ lib
				public WriteSoundFile() {
					this.pointer = allocate0();
				}
				
				public static WriteSoundFile allocate() {
					return new WriteSoundFile();
				}
				
				public static void free(WriteSoundFile wsf) {
					free0(wsf.pointer);
				}
				
				public void open(String file, int nChannels) {
					open0(file, nChannels, this.pointer);
				}
				
				public void open(String file, int nChannels, long type, long format) {
					open0(file, nChannels, type, format, this.pointer);
				}
	
				public void start(double[] input) {
					start0(input, this.pointer);
				}
				
				public void stop() {
					stop0(this.pointer);
				}
				
				public void print() {
					print0(this.pointer);
				}
}
