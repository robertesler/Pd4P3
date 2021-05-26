package com.pdplusplus;

/*
 * This is just a utility class for Sigmund.  Since Sigmund, in C++ returns a struct, we need
 * a class on the Java side to write all of the appropriate values to.  
 * This is the same as C++'s sigmundPackage{} struct. (except double pointers instead of arrays in C++)
 * */

public class SigmundPackage {
	
	public double pitch = 0;
    public double notes = 0;
    public double envelope = 0;
    public double[][] peaks;
    public double[][] tracks;
    public int peakSize = 0;
    public int trackSize = 0;
    
   
    public SigmundPackage() {
    	
    }
    
    public SigmundPackage(double p, double n, double e, double[][] peaks, double [][] tracks, int ps, int ts) {
    	this.pitch = p;
    	this.notes = n;
    	this.envelope = e;
    	this.peaks = peaks;
    	this.tracks = tracks;
    	this.peakSize = ps;
    	this.trackSize = ts;
    }
}
