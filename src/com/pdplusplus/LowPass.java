package com.pdplusplus;

public class LowPass extends PdMaster {

	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			
		 	private native double perform0(double input, long ptr);
	
		 	private native void setCutoff0(double cutoff, long ptr);
		 	private native void clear0(long ptr);
		 	
		 	 //These match the Pd++ lib
			public LowPass() {
				this.pointer = allocate0();
			}
			
			public static LowPass allocate() {
				return new LowPass();
			}
			
			public static void free(LowPass lop) {
				free0(lop.pointer);
			}
			
			public double perform(double input) {
				return perform0(input, this.pointer);
			}
			
			public void setCutoff(double cutoff) {
				setCutoff0(cutoff, this.pointer);
			}
	
			public void clear() {
				clear0(this.pointer);
			}
}
