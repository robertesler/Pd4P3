package com.pdplusplus;

/*
 * Super class for running DSP algorithms, similar to creating a Pd "patch"
 * You should only inherit this to another class in your Main class
 * or Processing Sketch.
 * */

public class PdAlgorithm extends PdMaster {

	//Open our Native Library
	static {
		//This is pd++ lib
		System.loadLibrary("pdplusplusTest");
	}
	
	//This is our output, you could create more channels if you like, just update play() channel count in Pd.java
		protected static double outputL = 0;
		protected static double outputR = 0;
	
	public void runAlgorithm(double inputL, double inputR)  {
		
	}
	
	public void free() {
		
	}
	
}
