package com.pdplusplus;

public class Line extends PdMaster {

	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native double perform0(double target, double time, long ptr);
	private static native void set0(double target, double time, long ptr);
	private static native void stop0(long ptr);
	
	 //These match the Pd++ lib
	public Line() {
		this.pointer = allocate0();
	}
	
	public static Line allocate() {
		return new Line();
	}
	
	public static void free(Line line) {
		free0(line.pointer);
	}
	
	public double perform(double target, double time) {
		return perform0(target, time, this.pointer);
	}
	
	public void set(double target, double time) {
		set0(target, time, this.pointer);
	}
	
	public void stop() {
		stop0(this.pointer);
	}
	
}
