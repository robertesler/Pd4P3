package com.pdplusplus;

/*
 * This is a collection of classes that include all of Pd's raw filters:
 * Real Pole [rpole~]
 * Real Zero [rzero~]
 * Real Zero Reverse [rzero_rev~]
 * 
 * Complex Pole [cpole~]
 * Complex Zero [czero~]
 * Complex Zero Reverse [czero_rev~]
 * 
 * Only use these if you know what you're doing.  But they can be used to create custom filters, EQs, etc.
 * */

public class ComplexZeroReverse extends PdMaster {
	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			private static native double[] perform0(double real, double imag, double realCoef, double imagCoef, long ptr);
			//! For real filters
			//private static native void set0(double value, long ptr);
		 
			//! For complex filters
		    private static native void set0(double real, double imaginary, long ptr);
			
		    //! For all types
			private static native void clear0(long ptr);
		    
			private static native void setLast0(double last, long ptr);
		    
			private static native void setLastReal0(double lastreal, long ptr);
		    
			private static native void setLastImaginary0(double lastimag, long ptr);
		    
			private static native double getLast0(long ptr);
		    
			private static native double getLastReal0(long ptr);
		    
			private static native double getLastImaginary0(long ptr);
			
			 //These match the Pd++ lib
			public ComplexZeroReverse() {
				this.pointer = allocate0();
			}
			
			public static ComplexZeroReverse allocate() {
				return new ComplexZeroReverse();
			}
			
			public static void free(ComplexZeroReverse czr) {
				free0(czr.pointer);
			}
			
			public double[] perform(double real, double imag, double realCoef, double imagCoef) {
				return perform0(real, imag,  realCoef, imagCoef, this.pointer);
			}
			
			public void set(double real, double imag) {
				set0(real, imag, this.pointer);
			}
			 
		    //! For all types
			public void clear() {
				clear0(this.pointer);
			}
		    
			public void setLast(double last) {
				setLast0(last, this.pointer);
			}
		    
			public void setLastReal(double lastreal) {
				setLastReal0(lastreal, this.pointer);
			}
		    
			public void setLastImaginary(double lastimag) {
				setLastImaginary0(lastimag, this.pointer);
			}
		    
			public double getLast() {
				return getLast0(this.pointer);
			}
		    
			public double getLastReal() {
				return getLastReal0(this.pointer);
			}
		    
			public double getLastImaginary() {
				return getLastImaginary0(this.pointer);
			}
		
	
}