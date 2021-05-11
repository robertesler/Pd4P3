package com.pdplusplus;

public class Threshold extends PdMaster {

	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			//returns 1 if you went above the threshold, or 0 if you went below the low threshold. -1 means neither, or that nothing has happened yet.
			private static native int perform0(double input, long ptr); 
			private static native void setValues0(double ht, double hd, double lt, double ld, long ptr); //high thresh, high debounce, low thresh, low debounce
			private static native void setState0(int s, long ptr);
			
			//These match the Pd++ lib
			public Threshold() {
				this.pointer = allocate0();
			}
			
			public static Threshold allocate() {
				return new Threshold();
			}
			
			public static void free(Threshold thresh) {
				free0(thresh.pointer);
			}
			
			public double perform(double index) {
				return perform0(index, this.pointer);
			}
			
			public void setValues(double ht, double hd, double lt, double ld) {
				 setValues0( ht,  hd,  lt,  ld,  this.pointer);
			}
			
			public void setState(int s) {
				setState0(s, this.pointer);
			}
}

