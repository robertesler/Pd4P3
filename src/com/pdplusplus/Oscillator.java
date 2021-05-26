package com.pdplusplus;

/*
 * A sine wave oscillator.  It takes a frequency, and it's phase can also be set by using setPhase().
 * It is actually a cosine wave as it starts at 1, but obviously you can make it a true sine wave by 
 * setting it's phase.  Phase should be based on 0 - 1 values, so .5 is equal to 180 degrees.
 * */

public class Oscillator extends PdMaster {
	
	
	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native void free0(long ptr);
	
	private native double perform0(double f, long ptr);
	private native void setPhase0(double ph, long ptr);
	
	//These match the Pd++ lib
	public Oscillator() {
		this.pointer = allocate0();
	}
	
	public static Oscillator allocate() {
		return new Oscillator();
	}
	
	public static void free(Oscillator osc) {
		Oscillator.free0(osc.pointer);
	}
	
	public double perform(double frequency) {
		return perform0(frequency, this.pointer);
	}
	
	public void setPhase(double phase) {
		setPhase0(phase, this.pointer);
	}
	
	
	public void test() {
		
		this.SET_DEBUG(false);
		
		Oscillator osc = new Oscillator();
		Oscillator osc2 = new Oscillator();
		Oscillator osc3 = new Oscillator();
		
		int numOfRuns = 100000;
		int counter = 0;
		long startTime = System.nanoTime();;
		
		for(int i = 0; i < numOfRuns; i++)
		{
			double output = osc.perform(100) * ((osc2.perform(1) * .5) + .5) * ((osc3.perform(2) * .5) + .5);
			if(this.DEBUG())
				System.out.printf("%d : %f%n", counter++, output);
		}

		long time = System.nanoTime() - startTime;
		
		System.out.printf("Each osc.perform averaged %,d ns%n", time/numOfRuns);
		System.out.printf("Total time was: %, d ns%n", time);
		Oscillator.free(osc);
		Oscillator.free(osc2);
	}
	
	

}
