package com.pdplusplus;

public class VariableDelay extends PdMaster {

	
	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	
	/*write to the delay first*/
	private static native void delayWrite0(double input, long ptr);
	private static native double delayRead0(double delayTime, long ptr);
    
    /*vd perform function*/
	private static native  double perform0(double delayTime, long ptr);
	
	//These match the Pd++ lib
	public VariableDelay() {
		this.pointer = allocate0();
	}
	
	public static VariableDelay allocate() {
		return new VariableDelay();
	}
	
	public static void free(VariableDelay vd) {
		free0(vd.pointer);
	}
	
	public double perform(double delayTime) {
		return perform0(delayTime, this.pointer);
	}
	
	public void delayWrite(double delayTime) {
		delayWrite0(delayTime, this.pointer);
	}
	
	double delayRead(double delayTime) {
		return delayRead0(delayTime, this.pointer);
	}
}
