package com.pdplusplus;


class RealPole extends PdMaster {
	
	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		private static native double perform0(double input, double coef, long ptr);
		//! For real filters
		private static native void set0(double value, long ptr);
	 
		//! For complex filters
	    //private static native void set0(double real, double imaginary);
		
	    //! For all types
		private static native void clear0(long ptr);
	    
		private static native void setLast0(double last, long ptr);
	    
		private static native void setLastReal0(double lastreal, long ptr);
	    
		private static native void setLastImaginary0(double lastimag, long ptr);
	    
		private static native double getLast0(long ptr);
	    
		private static native double getLastReal0(long ptr);
	    
		private static native double getLastImaginary0(long ptr);
		
		 //These match the Pd++ lib
		public RealPole() {
			this.pointer = allocate0();
		}
		
		public static RealPole allocate() {
			return new RealPole();
		}
		
		public static void free(RealPole rp) {
			free0(rp.pointer);
		}
		
		public double perform(double input, double coef) {
			return perform0(input, coef, this.pointer);
		}
		
		void set(double value) {
			set0(value, this.pointer);
		}
		 
	    //! For all types
		void clear() {
			clear0(this.pointer);
		}
	    
		void setLast(double last) {
			setLast0(last, this.pointer);
		}
	    
		void setLastReal(double lastreal) {
			setLastReal0(lastreal, this.pointer);
		}
	    
		void setLastImaginary(double lastimag) {
			setLastImaginary0(lastimag, this.pointer);
		}
	    
		double getLast() {
			return getLast0(this.pointer);
		}
	    
		double getLastReal() {
			return getLastReal0(this.pointer);
		}
	    
		double getLastImaginary() {
			return getLastImaginary0(this.pointer);
		}
	
}

class RealZero extends PdMaster {
	
	//These are the JNI functions
			public long pointer;
			
			private static native long allocate0();
			private static native void free0(long ptr);
			private static native double perform0(double input, double coef, long ptr);
			//! For real filters
			private static native void set0(double value, long ptr);
		 
			//! For complex filters
		    //private static native void set0(double real, double imaginary);
			
		    //! For all types
			private static native void clear0(long ptr);
		    
			private static native void setLast0(double last, long ptr);
		    
			private static native void setLastReal0(double lastreal, long ptr);
		    
			private static native void setLastImaginary0(double lastimag, long ptr);
		    
			private static native double getLast0(long ptr);
		    
			private static native double getLastReal0(long ptr);
		    
			private static native double getLastImaginary0(long ptr);
			
			 //These match the Pd++ lib
			public RealZero() {
				this.pointer = allocate0();
			}
			
			public static RealZero allocate() {
				return new RealZero();
			}
			
			public static void free(RealZero rz) {
				free0(rz.pointer);
			}
			
			public double perform(double input, double coef) {
				return perform0(input, coef, this.pointer);
			}
			
			void set(double value) {
				set0(value, this.pointer);
			}
			 
		    //! For all types
			void clear() {
				clear0(this.pointer);
			}
		    
			void setLast(double last) {
				setLast0(last, this.pointer);
			}
		    
			void setLastReal(double lastreal) {
				setLastReal0(lastreal, this.pointer);
			}
		    
			void setLastImaginary(double lastimag) {
				setLastImaginary0(lastimag, this.pointer);
			}
		    
			double getLast() {
				return getLast0(this.pointer);
			}
		    
			double getLastReal() {
				return getLastReal0(this.pointer);
			}
		    
			double getLastImaginary() {
				return getLastImaginary0(this.pointer);
			}
	
}

class RealZeroReverse extends PdMaster {
	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native double perform0(double input, double coef, long ptr);
	//! For real filters
	private static native void set0(double value, long ptr);
 
	//! For complex filters
    //private static native void set0(double real, double imaginary);
	
    //! For all types
	private static native void clear0(long ptr);
    
	private static native void setLast0(double last, long ptr);
    
	private static native void setLastReal0(double lastreal, long ptr);
    
	private static native void setLastImaginary0(double lastimag, long ptr);
    
	private static native double getLast0(long ptr);
    
	private static native double getLastReal0(long ptr);
    
	private static native double getLastImaginary0(long ptr);
	
	 //These match the Pd++ lib
	public RealZeroReverse() {
		this.pointer = allocate0();
	}
	
	public static RealZeroReverse allocate() {
		return new RealZeroReverse();
	}
	
	public static void free(RealZeroReverse rz) {
		free0(rz.pointer);
	}
	
	public double perform(double input, double coef) {
		return perform0(input, coef, this.pointer);
	}
	
	void set(double value) {
		set0(value, this.pointer);
	}
	 
    //! For all types
	void clear() {
		clear0(this.pointer);
	}
    
	void setLast(double last) {
		setLast0(last, this.pointer);
	}
    
	void setLastReal(double lastreal) {
		setLastReal0(lastreal, this.pointer);
	}
    
	void setLastImaginary(double lastimag) {
		setLastImaginary0(lastimag, this.pointer);
	}
    
	double getLast() {
		return getLast0(this.pointer);
	}
    
	double getLastReal() {
		return getLastReal0(this.pointer);
	}
    
	double getLastImaginary() {
		return getLastImaginary0(this.pointer);
	}
}

class ComplexPole extends PdMaster {
	
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
		public ComplexPole() {
			this.pointer = allocate0();
		}
		
		public static ComplexPole allocate() {
			return new ComplexPole();
		}
		
		public static void free(ComplexPole cp) {
			free0(cp.pointer);
		}
		
		public double[] perform(double real, double imag, double realCoef, double imagCoef) {
			return perform0(real, imag,  realCoef, imagCoef, this.pointer);
		}
		
		void set(double real, double imag) {
			set0(real, imag, this.pointer);
		}
		 
	    //! For all types
		void clear() {
			clear0(this.pointer);
		}
	    
		void setLast(double last) {
			setLast0(last, this.pointer);
		}
	    
		void setLastReal(double lastreal) {
			setLastReal0(lastreal, this.pointer);
		}
	    
		void setLastImaginary(double lastimag) {
			setLastImaginary0(lastimag, this.pointer);
		}
	    
		double getLast() {
			return getLast0(this.pointer);
		}
	    
		double getLastReal() {
			return getLastReal0(this.pointer);
		}
	    
		double getLastImaginary() {
			return getLastImaginary0(this.pointer);
		}
	
}

class ComplexZero extends PdMaster {
	
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
			public ComplexZero() {
				this.pointer = allocate0();
			}
			
			public static ComplexZero allocate() {
				return new ComplexZero();
			}
			
			public static void free(ComplexZero cz) {
				free0(cz.pointer);
			}
			
			public double[] perform(double real, double imag, double realCoef, double imagCoef) {
				return perform0(real, imag,  realCoef, imagCoef, this.pointer);
			}
			
			void set(double real, double imag) {
				set0(real, imag, this.pointer);
			}
			 
		    //! For all types
			void clear() {
				clear0(this.pointer);
			}
		    
			void setLast(double last) {
				setLast0(last, this.pointer);
			}
		    
			void setLastReal(double lastreal) {
				setLastReal0(lastreal, this.pointer);
			}
		    
			void setLastImaginary(double lastimag) {
				setLastImaginary0(lastimag, this.pointer);
			}
		    
			double getLast() {
				return getLast0(this.pointer);
			}
		    
			double getLastReal() {
				return getLastReal0(this.pointer);
			}
		    
			double getLastImaginary() {
				return getLastImaginary0(this.pointer);
			}
		
	
}

class ComplexZeroReverse extends PdMaster {
	
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
			
			void set(double real, double imag) {
				set0(real, imag, this.pointer);
			}
			 
		    //! For all types
			void clear() {
				clear0(this.pointer);
			}
		    
			void setLast(double last) {
				setLast0(last, this.pointer);
			}
		    
			void setLastReal(double lastreal) {
				setLastReal0(lastreal, this.pointer);
			}
		    
			void setLastImaginary(double lastimag) {
				setLastImaginary0(lastimag, this.pointer);
			}
		    
			double getLast() {
				return getLast0(this.pointer);
			}
		    
			double getLastReal() {
				return getLastReal0(this.pointer);
			}
		    
			double getLastImaginary() {
				return getLastImaginary0(this.pointer);
			}
		
	
}