package com.pdplusplus;

public class SampleHold extends PdMaster {

	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			private static native double perform0(double input, double control, long ptr);
			private static native void reset0(double value, long ptr);
			private static native void set0(double value, long ptr);
			
			//These match the Pd++ lib
			public SampleHold() {
				this.pointer = allocate0();
			}
			
			public static SampleHold allocate() {
				return new SampleHold();
			}
			
			public static void free(SampleHold samp) {
				free0(samp.pointer);
			}
			
			public double perform(double input, double control) {
				return perform0(input, control, this.pointer);
			}
			
			public void reset(double value) {
				reset0(value, this.pointer);
			}
			
			public void set(double value) {
				set0(value, this.pointer);
			}
			
}
