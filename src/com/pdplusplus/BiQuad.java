package com.pdplusplus;

public class BiQuad extends PdMaster {

	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		
	 	private native double perform0(double input, long ptr);

	 	private native void setCoefficients0(double fb1, double fb2, double ff1, double ff2, double ff3, long ptr);
	 	private native void set0(double a, double b, long ptr);
	 	
	 	 //These match the Pd++ lib
		public BiQuad() {
			this.pointer = allocate0();
		}
		
		public static BiQuad allocate() {
			return new BiQuad();
		}
		
		public static void free(BiQuad bq) {
			free0(bq.pointer);
		}
		
		public double perform(double input) {
			return perform0(input, this.pointer);
		}
		
		public void setCoefficients(double fb1, double fb2, double ff1, double ff2, double ff3) {
			setCoefficients0(fb1, fb2, ff1, ff2, ff3, this.pointer);
		}
		
		public void set(double a, double b) {
			set0(a, b, this.pointer);
		}

		
}
