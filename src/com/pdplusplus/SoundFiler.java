package com.pdplusplus;

public class SoundFiler extends PdMaster {

	//types
	 public final long FILE_RAW = 1;
	 public final long FILE_WAV = 2;
	 public final long FILE_SND = 3;
	 public final long FILE_AIF = 4;
	 public final long FILE_MAT = 5;
	
	//formats
	 public final long STK_SINT8   = 0x1;
	 public final long STK_SINT16  = 0x2;
	 public final long STK_SINT24  = 0x4;
	 public final long STK_SINT32  = 0x8;
	 public final long STK_FLOAT32 = 0x10;
	 public final long STK_FLOAT64 = 0x20;
	 
	//These are the JNI functions
	public long pointer;
		
	private static native long allocate0();
	private static native void free0(long ptr);
	private static native double read0(String file, long ptr);
    private static native void write0(String fileName,
               int nChannels,
               long type,
               long format,
               double [] array, long ptr);
    
    private static native double[] getArray0(long ptr);
    
    //These match the Pd++ lib
   	public SoundFiler() {
   		this.pointer = allocate0();
   	}
   	
   	public static SoundFiler allocate() {
   		return new SoundFiler();
   	}
   	
   	public static void free(SoundFiler wav) {
   		free0(wav.pointer);
   	}
   	
   	public double read(String file) {
   		return read0(file, this.pointer);
   	}
   	
   	public void write(String fileName, int nChannels, long type, long format, double [] array) {
   		write0(fileName, nChannels, type, format, array, this.pointer);
   	}
   	
   	public double[] getArray() {
   		return getArray0(this.pointer);
   	}
}
