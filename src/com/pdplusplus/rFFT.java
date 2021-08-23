package com.pdplusplus;

/*
 * Real Fast Fourier Transform.  Takes a signal input and returns a window of bins. 
 * The first half of the returned array is the real part, the second half is the imaginary.
 * */

public class rFFT extends PdMaster {

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native long allocate0(int window);
		private static native void free0(long ptr);
		private static native double[] perform0(double input, long ptr);
	
		//These match the Pd++ lib
		public rFFT() {
			this.pointer = allocate0();
		}
		
		public static rFFT allocate() {
			return new rFFT();
		}
		
		public rFFT(int window) {
			this.pointer = allocate0(window);
		}
		
		public static rFFT allocate(int window) {
			return new rFFT(window);
		}
		
		public static void free(rFFT rfft) {
			free0(rfft.pointer);
		}
		
		public double[] perform(double input) {
			return perform0(input, this.pointer);
		}
}
