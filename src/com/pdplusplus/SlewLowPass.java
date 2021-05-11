package com.pdplusplus;

public class SlewLowPass extends PdMaster {

	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native double perform0(double input, double freq, double posLimitIn, double posFreqIn, double negLimitIn, double negFreqIn, long ptr );
	private static native void set0(double last, long ptr);
	
	 //These match the Pd++ lib
	public SlewLowPass() {
		this.pointer = allocate0();
	}
	
	public static SlewLowPass allocate() {
		return new SlewLowPass();
	}
	
	public static void free(SlewLowPass slop) {
		free0(slop.pointer);
	}
	
	public double perform(double input, double freq, double posLimitIn, double posFreqIn, double negLimitIn, double negFreqIn) {
		return perform0(input, freq, posLimitIn, posFreqIn, negLimitIn, negFreqIn, this.pointer);
	}
	
	public void set(double last) {
		set0(last, this.pointer);
	}
}
