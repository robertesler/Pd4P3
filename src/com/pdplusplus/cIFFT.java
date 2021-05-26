package com.pdplusplus;

/*
 * Complex Inverse Fast Fourier Transform.  Takes an array of real and imaginary inputs.
 * The real and imaginary are interleaved from cFFT. 
 * It returns a pair of doubles, the real and imaginary part.
 * */

public class cIFFT extends PdMaster {
	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			
		 	private native double[] perform0(double [] input, long ptr);
		 	
		 	 //These match the Pd++ lib
		 	public cIFFT() {
				this.pointer = allocate0();
			}
			
			public static cIFFT allocate() {
				return new cIFFT();
			}
			
			public static void free(cIFFT ifft) {
				free0(ifft.pointer);
			}
			
			public double[] perform(double [] input) {
				return perform0(input, this.pointer);
			}

}
