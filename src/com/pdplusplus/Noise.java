package com.pdplusplus;

/*
 * A pseudo-random white noise generator.
 * */

public class Noise extends PdMaster {

	//This is the C++ class pointer 
	public long pointer;
	
	//These are the JNI functions
	private native static long allocate0();
	private native static void free0(long ptr);
	
	private native double perform0(long ptr);
	
	//These match the Pd++ library
	public Noise() {
		this.pointer = allocate0();
	}
	
	public static Noise allocate() {
		return new Noise();
	}
	
	//This must be called to free memory in the C++ lib
	public static void free(Noise noise) {
		Noise.free0(noise.pointer);
	}
	
	public double perform() {
		return perform0(this.pointer);
	}
	 
}
