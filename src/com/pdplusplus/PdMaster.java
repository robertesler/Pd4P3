package com.pdplusplus;

/*
 * This is the super class that all classes inherit.  It contains methods for setting the sample rate, block size, etc.
 * It also contains helpful conversion methods from Pd like midi to frequency, db to rms, etc.  
 * 
 * Pd for Processing 3, aka Pd++ for Java, is not meant to be a one-to-one representation of Pure Data objects in a 
 * programming language.  It is meant to provide the most essential signal processing objects in an object oriented
 * venue like Java or C++.  You still will have to do certain logic and math like you would in any other programming
 * language.  
 * 
 * Things like [moses] or [route] or [select] are not necessary because they can be accomplished by using standard
 * routines like if and switch statements.  
 * 
 * MIDI is also not included since that involves a separate interface.  MIDI is just data anyway and you can easily create
 * classes that handle MIDI like [makenote] yourself.  If you are interested in MIDI see portmidi or Java Sound's MIDI 
 * support.  They should work with Java or C++ and are probably thread safe for use with this library.  (fingers crossed
 * because I've never tested it with MIDI) : )
 * */


public class PdMaster {

	//Sample Rate and Blocks
	private native void setSampleRate0(long sr, long ptr);
    private native long getSampleRate0(long ptr);
    private native void setBlockSize0(int blockSize,long ptr);
    private native int getBlockSize0(long ptr);
    
    /*Converts samples into ms.*/
    private native double getTimeInSampleTicks0(long ptr);
    /*Converts milliseconds into samples/ms*/
    private native long getTimeInMilliSeconds0(double time, long ptr);
    
    //FFT Windowing
    private native void setFFTWindow0(int win, long ptr);
    private native int getFFTWindow0(long ptr);
    
    /*acoustic conversions live here*/
    private native double mtof0(double note, long ptr); // MIDI note number to frequency
    private native double ftom0(double freq, long ptr); // Frequency to MIDI note number
    private native double powtodb0(double num, long ptr);
    private native double dbtopow0(double num, long ptr);
    private native double rmstodb0(double num, long ptr);  // RMS (e.g 0-1) to dB (0-100)
    private native double dbtorms0(double num, long ptr);
	
    //For memory allocation only in C++, you should never directly create an instance of PdMaster
    private long pointer; // we're going to create a dummy class in C++ to inherit these functions from PdMaster.h
    private static native long allocate0();
    private static native void free0(long ptr);
    
    public PdMaster() {
    	this.pointer = allocate0();
    }
    
    public static void free(PdMaster pd) {
    	free0(pd.pointer);
    }
    
    /*
     * I am using this to include code at different points for debugging 
     * */
    private boolean debug = false;
    
    public boolean DEBUG() {
    	return debug;
    }
    
    public void SET_DEBUG(boolean d) {
    	debug = d;
    }
    
    /*
     * ***********************************
     * */
    
    public void setSampleRate(long sr) {
    	setSampleRate0(sr, this.pointer);
    }
    
    public long getSampleRate() {
    	return getSampleRate0(this.pointer);
    }
    
    public void setBlockSize(int blockSize) {
    	setBlockSize0(blockSize, this.pointer);
    }
    
    public int getBlockSize() {
    	return getBlockSize0(this.pointer);
    }
    
    public double getTimeInSampleTicks() {
    	return getTimeInSampleTicks0(this.pointer);
    }
    
    /*Converts milliseconds into samples/ms*/
    public long getTimeInMilliSeconds(double time) {
    	return getTimeInMilliSeconds0(time, this.pointer);
    }
    
    public void setFFTWindow(int win) {
    	setFFTWindow0(win, this.pointer);
    }
    
    public int getFFTWindow() {
    	return getFFTWindow0(this.pointer);
    }
    
    /*acoustic conversions live here*/
    public double mtof(double note)
    {
    	 return mtof0(note, this.pointer);// MIDI note number to frequency
    }
    
    public double ftom(double freq) {
    	return ftom0(freq, this.pointer);// Frequency to MIDI note number
    }
    
    public double powtodb(double num) {
    	return powtodb0(num, this.pointer);
    }
    
    public double dbtopow(double num) {
    	return dbtopow0(num, this.pointer);
    }
    
    public double rmstodb(double num) {
    	return rmstodb0(num, this.pointer);// RMS (e.g 0-1) to dB (0-100)
    }
    
    public double dbtorms(double num) {
    	return dbtorms0(num, this.pointer);
    }
}
