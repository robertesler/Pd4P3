package com.pdplusplus;

public class Convolution extends PdMaster {
	
	//These are the JNI functions
		public long pointer;
			
		private static native long allocate0();
		private static native long allocate0(int window, int overlap, long ptr);
		private static native void free0(long ptr);
	
		private static native double perform0(double filter, double control, long ptr);
		private static native void setSquelch0(int sq, long ptr);
		private static native int getSquelch0(long ptr);
		
		public Convolution() {
	   		this.pointer = allocate0();
	   	}
	   	
	   	public static Convolution allocate() {
	   		return new Convolution();
	   	}
	   	
	   	public Convolution(int window, int overlap) {
	   		this.pointer = allocate0(window, overlap, this.pointer);
	   	}
	   	
	   	public static Convolution allocate(int window, int overlap) {
	   		return new Convolution(window, overlap);
	   	}
	   	
	   	public static void free(Convolution conv) {
	   		free0(conv.pointer);
	   	}
	   	
	   	public double perform(double filter, double control) {
	   		return perform0(filter, control, this.pointer);
	   	}
	   	
	   	public void setSquelch(int sq) {
	   		setSquelch0(sq, this.pointer);
	   	}
	   	
	   	public int getSquelch() {
	   		return getSquelch0(this.pointer);
	   	}

}
