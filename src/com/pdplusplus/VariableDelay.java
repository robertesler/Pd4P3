package com.pdplusplus;

/*
 * A delay line that uses 4-point polynomial interpolation to read from a delay line.  
 * Use delayWrite() and delayRead() to write and read from the delay.  The input to the 
 * perform() method is the delayTime, so this could be combined with an oscillator to 
 * create some interesting effects.  
 * */

public class VariableDelay extends PdMaster {

	
	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native long allocate1(double deltime);
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
	
	public VariableDelay(double deltime) {
		this.pointer = allocate1(deltime);
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
	
	public void delayWrite(double data) {
		delayWrite0(data, this.pointer);
	}
	
	public double delayRead(double delayTime) {
		return delayRead0(delayTime, this.pointer);
	}
}
