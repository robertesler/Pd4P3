package com.pdplusplus;

/*
 * A uncompressed sound file reader.  This class will only read a file in small chunks,
 * and then play them back in a stream.
 * 
 * File formats include: .wav, .aif, .mat or .au
 * 
 * You can open the file with no onset, or some later start time
 * in milliseconds using the overloaded method.
 * 
 * You can change the buffer size using setBufferSize().  The size 
 * is in bits so 2^X, default is 1024 or 2^10.
 * 
 * Use start() and stop() to begin to read or stop.  
 * 
 * print() will print out details about the file.
 * */

public class ReadSoundFile extends PdMaster {

	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native void open0(String f, long ptr);
	private static native void open0(String file, double onset, long ptr);
	private static native double[] start0(long ptr);
	private static native void stop0(long ptr);
	private static native void print0(long ptr);
	private static native void setBufferSize0(int bits, long ptr);
	private static native int getBufferSize0(long ptr);
	private static native boolean isComplete0(long ptr);
	
	//These match the Pd++ lib
		public ReadSoundFile() {
			this.pointer = allocate0();
		}
		
		public static ReadSoundFile allocate() {
			return new ReadSoundFile();
		}
		
		public static void free(ReadSoundFile rsf) {
			free0(rsf.pointer);
		}

		public void open(String f) {
			open0(f, this.pointer);
		}
		
		//Open the file with an onset in milliseconds
		public void open(String f, double o) {
			open0(f, o, this.pointer);
		}
		
		public double[] start() {
			return start0(this.pointer);
		}
		
		public void stop() {
			stop0(this.pointer);
		}
		
		public void print() {
			print0(this.pointer);
		}
		
		public void setBufferSize(int bs) {
			setBufferSize0(bs, this.pointer);
		}
		
		public int getBufferSize() {
			return getBufferSize0(this.pointer);
		}
		
		public boolean isComplete() {
			return isComplete0(this.pointer);
		}
	
}
