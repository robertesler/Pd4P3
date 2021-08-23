package com.pdplusplus;

/*
 * Real Inverse Fast Fourier Transform.  Takes a window of real/imag values from rFFT.
 * */

public class rIFFT extends PdMaster {

	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native long allocate0(int window);
			private static native void free0(long ptr);
			private static native double perform0(double[] input, long ptr);
		
			//These match the Pd++ lib
			public rIFFT() {
				this.pointer = allocate0();
			}
			
			public static rIFFT allocate() {
				return new rIFFT();
			}
			
			public rIFFT(int window) {
				this.pointer = allocate0(window);
			}
			
			public static rIFFT allocate(int window) {
				return new rIFFT(window);
			}
			
			public static void free(rIFFT rifft) {
				free0(rifft.pointer);
			}
			
			public double perform(double[] input) {
				return perform0(input, this.pointer);
			}
}
