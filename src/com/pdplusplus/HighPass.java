package com.pdplusplus;

public class HighPass {

	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	
 	private native double perform0(double input, long ptr);

 	private native void setCutoff0(double cutoff, long ptr);
 	private native void clear0(long ptr);
 	
 	 //These match the Pd++ lib
	public HighPass() {
		this.pointer = allocate0();
	}
	
	public static HighPass allocate() {
		return new HighPass();
	}
	
	public static void free(HighPass hip) {
		free0(hip.pointer);
	}
	
	public double perform(double input) {
		return perform0(input, this.pointer);
	}
	
	public void setCutoff(double cutoff) {
		setCutoff0(cutoff, this.pointer);
	}	
	
	public void clear() {
		clear0(this.pointer);
	}
	
}
