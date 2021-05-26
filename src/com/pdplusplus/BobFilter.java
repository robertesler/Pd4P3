package com.pdplusplus;

/*
 * From: https://github.com/pure-data/pure-data/tree/master/extra/bob~
 * "Imitates a Moog resonant filter by Runge-Kutte numerical integration of
a differential equation approximately describing the dynamics of the circuit."

So it's basically a resonant filter...
 * */

public class BobFilter extends PdMaster {
	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			
		 	private native double perform0(double input, long ptr);
	
		 	private native void setCutoffFrequency0(double cf, long ptr);
		 	private native void setResonance0(double r, long ptr);
		 	private native void setSaturation0(double s, long ptr);
		 	private native void setOversampling0(double o, long ptr);
		 	private native double getCutoffFrequency0(long ptr);
		 	private native double getResonance0(long ptr);
		 	private native void error0(long ptr);
		 	private native void clear0(long ptr);	
		 	private native void print0(long ptr);
		 	
		 	 //These match the Pd++ lib
			public BobFilter() {
				this.pointer = allocate0();
			}
			
			public static BobFilter allocate() {
				return new BobFilter();
			}
			
			public static void free(BobFilter bob) {
				free0(bob.pointer);
			}
			
			public double perform(double input) {
				return perform0(input, this.pointer);
			}
			
		 	public void setCutoffFrequency(double cf) {
		 		setCutoffFrequency0(cf, this.pointer);
		 	}
		 	
		 	public void setResonance(double r) {
		 		setResonance0(r, this.pointer);
		 	}
		 	
		 	public void setSaturation(double s) {
		 		setSaturation0(s, this.pointer);
		 	}
		 	
		 	public void setOversampling(double o) {
		 		setOversampling0(o, this.pointer);
		 	}
		 	
		 	public double getCutoffFrequency() {
		 		return getCutoffFrequency0(this.pointer);
		 	}
		 	
		 	public double getResonance() {
		 		return getResonance0(this.pointer);
		 	}
		 	
		 	public void error() {
		 		error0(this.pointer);
		 	}
		 	
		 	public void clear() {
		 		clear0(this.pointer);
		 	}
		 	
		 	public void print() {
		 		print0(this.pointer);
		 	}
			
			
}
