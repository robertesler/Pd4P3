package com.pdplusplus;

/*
 * Band pass filter.  Takes a signal input. You can set the center frequency using setCenterFrequency(double) or
 * set the Q using setQ(double).  
 * */

public class BandPass extends PdMaster {

	
	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		
	 	private native double perform0(double input, long ptr);
	    private native void setCenterFrequency0(double cf, long ptr);
	    private native void setQ0(double q, long ptr);
	    private native void clear0(long ptr);
	
	  //These match the Pd++ lib
		public BandPass() {
			this.pointer = allocate0();
		}
		
		public static BandPass allocate() {
			return new BandPass();
		}
		
		public static void free(BandPass bp) {
			free0(bp.pointer);
		}
		
		public double perform(double input) {
			return perform0(input, this.pointer);
		}
		
		public void setCenterFrequency(double cf) {
			setCenterFrequency0(cf, this.pointer);
		}
		
		public void setQ(double q) {
			setQ0(q, this.pointer);
		}
		
		public void clear() {
			clear0(this.pointer);
		}
	    
}
