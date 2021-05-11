package com.pdplusplus;

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
