package com.pdplusplus;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

class Main extends Thread {
	
	//In Processing you would need to create a Pd singleton
	 static Pd pd = Pd.getInstance();
	 //And an instance of your inherited class, may look different from below
	 static MyMusic music = new Main(). new MyMusic();
	 
	 static Main m = new Main();
	 public static boolean play = true;
	
	 /*
	  * Run a separate thread to get user input from console to quit program
	  * This throws a jPortAudio error about thread execution on Pd.stop();
	  * Still looking into this...
	  * */
	 public void run() {
			System.out.println("Enter 'q' to quit: ");
		    // Enter data using BufferReader
		    BufferedReader reader = new BufferedReader(
		        new InputStreamReader(System.in));

		    // Reading data using readLine
		    String name = "";
			try {
				name = reader.readLine();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	    
		    if(name.contentEquals("q"))
		    {
		    	Pd.stop(music); //this would go in the dispose() method
				System.out.println("Audio was stopped.");
		    	
		    }
		}
	 
	 synchronized static void setPlay(boolean p) { 
		
			 play = p;
		 
	 }
	 
	 synchronized static boolean getPlay() {
		
			return play;
		 
	 }
	 
	public static void main(String [] args)  {
	
			m.start();
			Pd.start(music); //This would go in the setup() method
		
	}

	/*
	 *This is how you would use Pd++ in Processing 
	 * */
	
	class MyMusic extends PdAlgorithm {
		
		//create new objects like this
		Oscillator osc1 = new Oscillator();
		
		@Override
		//All of your DSP code goes here
		public void runAlgorithm(double inputL, double inputR) {
			outputL = outputR = osc1.perform(300);
		}
		
		@Override
		//Always free your objects created above, this will avoid memory leaks in the native C++ library
		public void free() {
			Oscillator.free(osc1);
		}
		
	}
	
}
