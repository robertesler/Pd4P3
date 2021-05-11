package com.pdplusplus;

public class Delay extends PdMaster {

	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native double perform0(double input, long ptr);
	private static native void setDelayTime0(double time, long ptr);
	private static native void reset0(long ptr);
	
	 //These match the Pd++ lib
	public Delay() {
		this.pointer = allocate0();
	}
	
	public static Delay allocate() {
		return new Delay();
	}
	
	public static void free(Delay del) {
		free0(del.pointer);
	}
	
	public double perform(double input) {
		return perform0(input, this.pointer);
	}
	
	public void setDelayTime(double time) {
		setDelayTime0(time, this.pointer);
	}
	
	public void reset() {
		reset0(this.pointer);
	}
	
}
