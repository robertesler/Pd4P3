package com.pdplusplus;

public class PhaseVocoder extends PdMaster {

	//These are the JNI functions
	public long pointer;
			
	private static native long allocate0();
	private static native long allocate0(int ws, int o);
	private static native void free0(long ptr);		
	private native double perform0(long ptr);
	private native void inSample0(String file, long ptr);
	private native void setSpeed0(double s, long ptr);
	private native void setTranspo0(double t, long ptr);
	private native void setLock0(int l, long ptr);
	private native void setRewind0(long ptr);
	
	//These match the Pd++ lib
	public PhaseVocoder() {
		this.pointer = allocate0();
	}
	
	public PhaseVocoder(int ws, int o) {
		this.pointer = allocate0(ws, o);
	}
	
	public static PhaseVocoder allocate() {
		return new PhaseVocoder();
	}
	

	public static void free(PhaseVocoder pvoc) {
		free0(pvoc.pointer);
	}
	
	public double perform() {
		return perform0(this.pointer);
	}
	
	public void inSample(String file) {
		inSample0(file, this.pointer);
	}
	
	public void setSpeed(double s) {
		setSpeed0(s, this.pointer);
	}
	
	public void setTranspo(double t) {
		setTranspo0(t, this.pointer);
	}
	
	public void setLock(int l) {
		setLock0(l, this.pointer);
	}
	
	public void setRewind() {
		setRewind0(this.pointer);
	}
}
