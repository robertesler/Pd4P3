package com.pdplusplus;

/*
 * This is a one pole complex filter.  It outputs a real and imaginary value which ultimately
 * correlate to the resonant low pass and bandpass values respectively.  It outputs a pair of values, 
 * e.g the lowpass and bandpass pairs.  You can use one or both.  
 * 
 * The center frequency and Q can also be set at the signal level for interesting effects.
 * */

public class VoltageControlFilter extends PdMaster {
	
	//These are the JNI functions
		public long pointer;
		
		
		private static native long allocate0();
		private static native void free0(long ptr);
		
	 	private native double[] perform0(double input, double cf, long ptr);

	 	private native void setQ0(double q, long ptr);
	 	
	 	 //These match the Pd++ lib
		public VoltageControlFilter() {
			this.pointer = allocate0();
		}
		
		public static VoltageControlFilter allocate() {
			return new VoltageControlFilter();
		}
		
		public static void free(VoltageControlFilter vcf) {
			free0(vcf.pointer);
		}
		
		public double[] perform(double input, double cf) {
			return perform0(input, cf, this.pointer);
		}
		
		public void setQ(double q) {
			setQ0(q, this.pointer);
		}	
		
		
}



