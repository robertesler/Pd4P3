package com.pdplusplus;

public class Envelope extends PdMaster {

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		private static native double perform0(double input, long ptr);
		//setters
		private static native void setWindowSize0(int ws, long ptr);
		private static native void setPeriod0(int p, long ptr);
	    //getters
		private static native int getWindowSize0(long ptr);
		private static native int getPeriod0(long ptr);
		
		 //These match the Pd++ lib
		public Envelope() {
			this.pointer = allocate0();
		}
		
		public static Envelope allocate() {
			return new Envelope();
		}
		
		public static void free(Envelope env) {
			free0(env.pointer);
		}
		
		public double perform(double input) {
			return perform0(input, this.pointer);
		}
		
		public void setWindowSize(int ws) {
			setWindowSize0(ws, this.pointer);
		}
		
		public void setPeriod(int p) {
			setPeriod0(p, this.pointer);
		}
		
		public int getWindowSize() {
			return getWindowSize0(this.pointer);
		}
		
		public int getPeriod() {
			return getPeriod0(this.pointer);
		}
}
