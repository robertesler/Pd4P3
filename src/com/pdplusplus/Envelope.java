package com.pdplusplus;

/*
 * This is an envelope follower.  It's output of the perform() method is in dB.  The speed of this method is
 * based on the period and window size, which can be set via the constructor. 
 * */

public class Envelope extends PdMaster {

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native long allocate1(int ws, int p);
		private static native void free0(long ptr);
		private static native double perform0(double input, long ptr);
		
		
		 //These match the Pd++ lib
		public Envelope() {
			this.pointer = allocate0();
		}

		public Envelope(int windowSize, int period) {
			this.pointer = allocate1(windowSize, period);
		} 
		
		public static Envelope allocate() {
			return new Envelope();
		}

		public static Envelope allocate(int ws, int p) {
			return new Envelope(ws, p);
		}
		
		public static void free(Envelope env) {
			free0(env.pointer);
		}
		
		public double perform(double input) {
			return perform0(input, this.pointer);
		}
		
	
}
