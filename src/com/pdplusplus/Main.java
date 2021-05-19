package com.pdplusplus;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

class Main  {
		
	//And an instance of your inherited class, may look different from below
	static MyMusic music = new Main(). new MyMusic();
	//In Processing you would need to create a Pd singleton
	//static Pd pd = Pd.getInstance(music);
	static Pd pd = Pd.getInstance(music); 
	
	public static float freq1 = 400;
	 
	public static void main(String [] args)  {
	   
		/*
		 * This is run on a separate thread
		 * */

		pd.start(); //This would go in the Processing setup() method
		
		/*
		 * This is run on the main thread
		 * */
		boolean inputRun = true;
		while(inputRun)
		{
			System.out.println("Enter 'q' to quit: ");
			// Enter data using BufferReader
			BufferedReader reader = new BufferedReader(
					new InputStreamReader(System.in));

			// Reading data using readLine
			String name = "";
			try {
				name = reader.readLine();
			} catch (IOException e) {
				e.printStackTrace();
			}
		
		
			if(isNumeric(name))
			{
				freq1 = Float.parseFloat(name);
				music.setFreq(freq1);
				System.out.println("freq: " + freq1);
			}
			else if(name.contentEquals("q"))
			{
				inputRun = false;
				pd.stop(); //this would go in the dispose() method
				System.out.println("Audio was stopped.");	
			}
			
		}
		
	}
	
	/*
	 * Check if our input is a number
	 * */
	public static boolean isNumeric(String strNum) {
	    if (strNum == null) {
	        return false;
	    }
	    try {
	        double d = Double.parseDouble(strNum);
	    } catch (NumberFormatException nfe) {
	        return false;
	    }
	    return true;
	}

	/*
	 *This is how you would use Pd++ in Processing , inherit the PdAlgorithm class
	 * */
	
	class MyMusic extends PdAlgorithm {
		
		//create new objects like this
		Oscillator osc1 = new Oscillator();
		Oscillator osc2 = new Oscillator();
		float oscFreq = 300;
		
		@Override
		//All of your DSP code goes here
		public void runAlgorithm(double inputL, double inputR) {
			
			outputL = outputR = osc1.perform(getFreq()) * .5 + osc2.perform(getFreq() * 1.5) *.5;
//			outputL = inputL;
//			outputR = inputR;
		}
		
		@Override
		//Always free your Pd++ objects created above, this will avoid memory leaks in the native C++ library
		public void free() {
			Oscillator.free(osc1);
			Oscillator.free(osc2);
		}
		
		//synchronized will update the audio thread
		 synchronized void setFreq(float freq1) {
			oscFreq = freq1;
			System.out.println("Main: setFreq(freq1) = " + freq1);
		}
		
		//updates freq
		float getFreq() {
			return oscFreq;
		}
		
	}
	
}
