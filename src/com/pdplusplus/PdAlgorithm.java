package com.pdplusplus;

/*
 * Super class for running DSP algorithms, similar to creating a Pd "patch"
 * You should only inherit this to another class in your Main class
 * or Processing Sketch.
 * 
 * @author Robert Esler
 * */

public class PdAlgorithm extends PdMaster {

	//Open our Native Library
	static {
		/*
		 * This is the pd++ lib
		 * */
		System.loadLibrary("pdplusplusTest");
		System.out.println("Attempting to load pdplusplus.dll");
	}
	
	//This is our output, you could create more channels if you like, see the writeData method and constructor in Pd.java
		protected static double outputL = 0;
		protected static double outputR = 0;
	
		/*
		 * This is where all of your DSP should go.  The inputL/R are from the system's input stream.
		 * For all classes except PdMaster and Pd, use the perform() method.  The perform() method calculates the signal
		 * for each class.  You can use the other methods to set parameters, access features, etc.
		 * 
		 * This function should write directly to outputL and outputR respectively.  Those variables are what ultimately
		 * get sent to the audio driver/hardware.  
		 * */
	public void runAlgorithm(double inputL, double inputR)  {
		
	}
	
	public void free() {
		
	}
	
}
