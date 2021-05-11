package com.pdplusplus;

public class Cosine extends PdMaster {
	
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	
	private native double perform0(double f, long ptr);
	
	//These match the Pd++ lib
		public Cosine() {
			this.pointer = allocate0();
		}
		
		public static Cosine allocate() {
			return new Cosine();
		}
		
		public static void free(Cosine cos) {
			free0(cos.pointer);
		}
		
		public double perform(double f) {
			return perform0(f, this.pointer);
		}

}
