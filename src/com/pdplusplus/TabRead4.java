package com.pdplusplus;

/*
 * TabRead4 is a table reader that uses 4-point polynomial interpolation.  You will need to create
 * an array for it to read.  This is good for file playback or wavetable synthesizers, among other things.
 * I think it sounds better than linear interpolation but call me a polygnome!
 * */

public class TabRead4 extends PdMaster {

	 	
	//These are the JNI functions
		public long pointer;
		
		private static native long allocate0();
		private static native void free0(long ptr);
		private static native double perform0(double index, long ptr);
	    
	    /*getters and setters*/
		private static native void setTable0(double[] table, long ptr);
		private static native long getTableSize0(long ptr);
		private static native void setOnset0(double point, long ptr);
		private static native double getOnset0(long ptr);
		
		//These match the Pd++ lib
		public TabRead4() {
			this.pointer = allocate0();
		}
		
		public static TabRead4 allocate() {
			return new TabRead4();
		}
		
		public static void free(TabRead4 tab) {
			free0(tab.pointer);
		}
		
		public double perform(double index) {
			return perform0(index, this.pointer);
		}
		
		public void setTable(double[] table) {
			setTable0(table, this.pointer);
		}
		
		public long getTableSize() {
			return getTableSize0(this.pointer);
		}
		
		public void setOnset(double point) {
			setOnset0(point, this.pointer);
		}
		
		public double getOnset() {
			return getOnset0(this.pointer);
		}
}
