package com.pdplusplus;

public class rFFT extends PdMaster {

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		private static native double[] perform0(double input, long ptr);
	
		//These match the Pd++ lib
		public rFFT() {
			this.pointer = allocate0();
		}
		
		public static rFFT allocate() {
			return new rFFT();
		}
		
		public static void free(rFFT rfft) {
			free0(rfft.pointer);
		}
		
		public double[] perform(double input) {
			return perform0(input, this.pointer);
		}
}
