package com.pdplusplus;

public class cFFT extends PdMaster{

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		
	 	private native double[] perform0(double real, double imaginary, long ptr);
	 	
	 	 //These match the Pd++ lib
	 	public cFFT() {
			this.pointer = allocate0();
		}
		
		public static cFFT allocate() {
			return new cFFT();
		}
		
		public static void free(cFFT fft) {
			free0(fft.pointer);
		}
		
		public double[] perform(double real, double imag) {
			return perform0(real, imag, this.pointer);
		}
	 	
	
}
