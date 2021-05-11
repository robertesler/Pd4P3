package com.pdplusplus;

public class rIFFT extends PdMaster {

	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			private static native double perform0(double[] input, long ptr);
		
			//These match the Pd++ lib
			public rIFFT() {
				this.pointer = allocate0();
			}
			
			public static rIFFT allocate() {
				return new rIFFT();
			}
			
			public static void free(rIFFT rifft) {
				free0(rifft.pointer);
			}
			
			public double perform(double[] input) {
				return perform0(input, this.pointer);
			}
}
