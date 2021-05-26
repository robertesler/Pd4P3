package com.pdplusplus;

/*
 * A sawtooth (ramp) wave generator.  Its output is 0-1.  You can combine this with Cosine to
 * create a cosine wave.  Just FYI.  : )
 * */

public class Phasor extends PdMaster {
	
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	
	private native double perform0(double f, long ptr);
	private native void setPhase0(double ph, long ptr);
	private native double getPhase0(long ptr);
	private native void setFrequency0(double freq, long ptr);
	private native double getFrequency0(long ptr);
	
	//These match the Pd++ lib
	public Phasor() {
		this.pointer = allocate0();
	}
	
	public static Phasor allocate() {
		return new Phasor();
	}
	
	public static void free(Phasor ph) {
		free0(ph.pointer);
	}
	
	public double perform(double f) {
		return perform0(f, this.pointer);
	}
	
	public void setPhase(double phase) {
		setPhase0(phase, this.pointer);
	}
	
	public double getPhase() {
		return getPhase0(this.pointer);
	}
	
	public void setFrequency(double freq) {
		setFrequency0(freq, this.pointer);
	}
	
	public double getFrequency() {
		return getFrequency0(this.pointer);
	}
	

}
