package com.pdplusplus;

public class Sigmund extends PdMaster {
	
	//These are the JNI functions
	public long pointer;
	
	private static native long allocate0();
	private static native long allocate0(String p, String e);
	private static native long allocate0(String t, int n);
	private static native void free0(long ptr); 
	private static native SigmundPackage perform0(double input, long ptr);
	private static native void setMode0(int mode, long ptr);
	private static native void setNumOfPoints0(double n, long ptr);
	private static native void setHop0(double h, long ptr);
	private static native void setNumOfPeaks0(double p, long ptr);
	private static native void setMaxFrequency0(double mf, long ptr);
	private static native void setVibrato0(double v, long ptr);
	private static native void setStableTime0(double st, long ptr);
	private static native void setMinPower0(double mp, long ptr);
	private static native void setGrowth0(double g, long ptr);
	private static native void print0(long ptr);//print all parameters
	private static native SigmundPackage list0(double[] array, int numOfPoints, int index, long sr, int debug, long ptr);//read from an array
	private static native void clear0(long ptr);
	    
	    //getters
	private static native int getMode0(long ptr);
	private static native double getNumOfPoints0(long ptr);
	private static native double getHop0(long ptr);
	private static native double getNumOfPeaks0(long ptr);
	private static native double getMaxFrequency0(long ptr);
	private static native double getVibrato0(long ptr);
	private static native double getStableTime0(long ptr);
	private static native double getMinPower0(long ptr);
	private static native double getGrowth0(long ptr);
	
	//These match the Pd++ lib
	public Sigmund() {
		this.pointer = allocate0();
	}
	
	public Sigmund(String p, String e) {
		this.pointer = allocate0(p, e);
	}//pitch, env
	
    public Sigmund(String t, int numOfPeaks) {
    	this.pointer = allocate0(t, numOfPeaks);
    }//tracks or peaks
	
    public static Sigmund allocate() {
    	return new Sigmund();
    }
    
    public static Sigmund allocate(String p, String e) {
    	return new Sigmund(p, e);
    }
    
    public static Sigmund allocate(String t, int n) {
    	return new Sigmund(t, n);
    }
    
    public static void free(Sigmund s) {
		free0(s.pointer);
	}
    
    public SigmundPackage perform(double input) {
    	return perform0(input, this.pointer);
    }
    
	public void setMode(int mode) {
		setMode0(mode, this.pointer);
	}
	
	public void setNumOfPoints(double n) {
		setNumOfPoints0(n, this.pointer);
	}
	
	public void setHop(double h) {
		setHop0(h, this.pointer);
	}
	
	public void setNumOfPeaks(double p) {
		setNumOfPeaks0(p, this.pointer);
	}
	
	public void setMaxFrequency(double mf) {
		setMaxFrequency0(mf, this.pointer);
	}
	
	public void setVibrato(double v) {
		setVibrato0(v, this.pointer);
	}
	
	public void setStableTime(double st) {
		setStableTime0(st, this.pointer);
	}
	
	public void setMinPower(double mp) {
		setMinPower0(mp, this.pointer);
	}
	
	public void setGrowth(double g) {
		setGrowth0(g, this.pointer);
	}
	
	public void print() {
		print0(this.pointer);
	}
	
	public SigmundPackage list(double[] array, int numOfPoints, int index, long sr, int debug, long ptr) {
		return list0(array, numOfPoints, index, sr, debug, this.pointer);
	}
	
	public void clear() {
		clear0(this.pointer);
	}
	    
	    //getters
	public int getMode() {
		return getMode0(this.pointer);
	}
	
	public double getNumOfPoints() {
		return getNumOfPoints0(this.pointer);
	}
	
	public double getHop() {
		return getHop0(this.pointer);
	}
	
	public double getNumOfPeaks() {
		return getNumOfPeaks0(this.pointer);
	}
	
	public double getMaxFrequency() {
		return getMaxFrequency0(this.pointer);
	}
	
	public double getVibrato() {
		return getVibrato0(this.pointer);
	}
	
	public double getStableTime() {
		return getStableTime0(this.pointer);
	}
	
	public double getMinPower() {
		return getMinPower0(this.pointer);
	}
	
	public double getGrowth() {
		return getGrowth0(this.pointer);
	}
    
    
}
