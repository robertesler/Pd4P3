# Pd4P3
A java implementation of the Pd++ library, a C++ native library of Pure Data's signal objects.  This library will also work in Processing 3. 

# Copyright
This software is copyrighted by Robert Esler, 2021.  

# Author(s)
Pd4P3 is written by Robert Esler with much help from Lisa Tolentino.  Pd++ is written by Robert Esler.  Pure Data is written by Miller Puckette and others:  see https://github.com/pure-data/pure-data

# P3 library
You can download the Processing library here: https://bit.ly/3yS8XB7

# Pd++
Pd++ is a standalone C++ library based on the signal objects of Pure Data.  More information can be found here: https://bitbucket.org/resler/pd/src/master/

# Versions (Win/MacOS)
This version of the library right now only works on Windows 10 and MacOS.  The .dll in the /lib folder are built for Windows, the .dylibs are for MacOS.  If you want to use this on Linux then for now you would have to build Pd++, portaudio and jPortAudio for your architecture.  This will be updated soon to a Linux build option. 

# How Pd4P3 Works
Pd4P3 stands for "Pd++ for Processing 3". The backbone of the library is written in C++ and accessed via the Java Native Interface (JNI).  Pd++ is a C++ implementation of most of Pure Data's signal processing objects, so what you make in Pure Data should sound the same in Pd++ or Pd4P3, theoretically.  The syntax is also the same between Pd++ and Pd4P3, so what you write in Processing using this library should be able to be copied and pasted to a C++ project, like a JUCE plugin for example, with a few minor alterations.  This way you can test out your ideas quickly in Pure Data, implement a prototype in Processing and then easily deploy the same code to an audio plugin format.  There are obviously a few more steps to actually accomplish this but that would be the workflow.

The backend of Pd4P3 uses the Java Sound API with the option of JPortAudio for Win/MacOS.  There are some latency issues with JPortAudio and MacOS I am still trying to figure out, but both JPortAudio and the Java Sound API work fine in Windows 10.  

The classes in Pd4P3 function like most Java classes, there is input to the class methods, like a frequency, and output, a sine wave.  There is nothing special to the signal chain, the output or return value of every signal object, with a few exceptions like FFT, is a double precision number.  You can add/subtract/multiply/divide these numbers with other objects and make complex processes/synthesizers/etc.  Unlike Java Sound or JSyn (which is still awesome btw), there are no abstract concepts like Mixers, Lines, Ports, Circuits, Synthesizers, Instruments, etc.  Pd4P3 is always just numbers, just like in Pure Data, and you can deal with those numbers how you like.  

# Pure Data to Pd4P3 object table
These are the Pd objects emulated in Pd4P3.
Class    |   Pd Object
---------| ------------
BandPass |   [bp~] 
BiQuad    |  [biquad~]
BobFilter  | [bob~]
Cosine     | [cos~]
Delay      | [delwrite~] and [delread~]
Envelope   | [env~]
HighPass   | [hip~]
Line       | [line~]
LowPass    | [lop~]
Noise      | [noise~]
Oscillator | [osc~]
Phasor     | [phasor~]
Included in RawFilter:
  RealPole | [rpole~]
  RealZero | [rzero~]
  RealZeroReverse | [rzero_rev~]
  ComplexPole | [cpole~]
  ComplexZero | [czero~]
  ComplexZeroReverse | [czero_rev~]
SampleHold | [samphold~]
Sigmund    | [sigmund~]
SlewLowPass | [slop~]
SoundFiler | [soundfiler~]
TabRead4   | [tabread4]
Threshold  | [threshold~]  
VariableDelay | [vd~] and [delwrite~]
VoltageControlFilter | [vcf~]
cFFT     |   [fft~]
cIFFT    |   [ifft~]
rFFT      |  [rfft~]
rIFFT     |  [rifft~]
PdMaster, which is the superclass to all Pd4P3 classes, also has a few utility methods
dbtorms() |  [dbtorms]
rmstodb() |  [rmstodb]
mtof()    |  [mtof]
ftom()    |  [ftom]
powtodb() |  [powtodb]
dbtopow() | [dbtopow]

The only major missing Pd objects are [readsf~] and [writesf~] which read/write sound files directly from disk, not into RAM.  Since this is usually something you would use to play long sound files I have not included yet in the library.  If this is your main goal then you can either use Java's sound file read/write capabilities, another library, or just use SoundFiler which will read the file into RAM first.  

What about [adc~] and [dac~]?  The PdAlgorithm abstract class handles input and output.  You will see a method called `runAlgorithm(double in1, double in2)` the arguments represent the input from the microphone(s) and the public members `outputL` and `outputR` represent the output to the system.  

Otherwise everything else in Pd can be easily implemented using standard Java methods or syntax, like math (+ - * /) or Math.sqrt, or basic logic used in [sel], [moses], [route] using if or switch statements.  Any questions just contact the author: robertesler.

# Test in Processing 3

1. Download or clone this repository.
2. Download Ant (https://ant.apache.org/bindownload.cgi) and install
3. Navigate to the repository home folder using the Command Line
4. Type: `ant`
5. Then type: `ant install`, this make a Processing-ready library dummy folder and a .zip file in the directory just above the repository.
6. Copy the .zip file to ~/Documents/Processing/libraries/ and then unzip the file
7. Open Processing and find a Pd4P3 example.  
8. Open the example and run it.  
9. Hopefully it works.  If not submit an issue.

# Using Eclipse
You can use this library with just pure good old Java too.  Here are the steps to use with Eclipse.
STEP 1. Download Eclipse for Java (eclipse.org)

STEP 2. Clone or download the source to Pd4P3 and export it to known folder location you have access to.

STEP 3. Open up Eclipse, choosing to Create a Java Project.

STEP 4. Name your project. Go to next screen.

STEP 5. Under Java Settings, choose the Libraries tab. Under Modulepath, click the carrot next to JRE System Library to reveal the property, Native library location: (None)

STEP 6. Click on the Native library location, then click the Edit... button.

STEP 7. For Location Path, navigate to the extracted folder, Pd4P3, containing all the .dlls.
** This is the same as right-clicking on the project folder later and Configuring the Build Path
** Be sure to click the button, "Apply and Close" to apply the new library.

STEP 8. Right-click on the project folder and select "Import". Then, click the triangle for General to expose the File System option; select it and click Next.

STEP 9. In the File system options, for From directory, browse to and select the "PD++4Java/src" folder. Click the src's checkbox; this imports its resources (Java class sources) to your project. Click Finish.

STEP 10. In the com.pdplusplus package, open up the classes and navigate to the Main.java

STEP 11. Double-click on Main.java; this is where the driver, or 
public static void main(String[] args)
lives. 

STEP 12.  Edit the void runAlgorithm() method in the MyMusic class to begin writing DSP code.
