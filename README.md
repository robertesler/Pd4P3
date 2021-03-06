# Pd4P3
A real-time audio synthesis library for Processing 3. Pd4P3 implements Pure Data's signal processing objects via Pd++ native code.  Pd4P3 stands for "Pd++ for Processing 3".

# Copyright
This software is copyrighted by Robert Esler, 2021.  

# Author(s)
Pd4P3 is written by Robert Esler with much help from Lisa Tolentino.  Pd++ is written by Robert Esler.  Pure Data is written by Miller Puckette and others:  see https://github.com/pure-data/pure-data

# P3 library
You can download the Processing  library via the Contribution Manager or here: https://www.robertesler.com/software/Pd4P3.zip
This is a 20-minute tutorial if you need it: https://youtu.be/zxsB6UWKb6g

# Tutorials
If you like video tutorials, I have several now here: https://www.youtube.com/channel/UCZhuqrgHls7AybMDKysnJaQ

# Pd++
Pd++ is a standalone C++ library based on the signal objects of Pure Data.  More information can be found here: https://bitbucket.org/resler/pd/src/master/

# Versions (Win/MacOS/Linux/Rpi)
This version of the library right now works on Windows 10, MacOS and Linux Ubuntu 20.x.  The .dll in the /library folder are built for Windows, the .dylibs are for MacOS, the .so for linux.  The linux version does not have support for PortAudio right now.  This library has also been tested on the Raspberry Pi and works as expected based on the limitations of the hardware.  I am able to get full duplex audio on an Rpi 3 with an occasional audio interruption. More details below on how to build for the Rpi.
  

# How Pd4P3 Works
The backbone of the library is written in C++ and accessed via the Java Native Interface (JNI).  Pd++ is a C++ implementation of most of Pure Data's signal processing objects, so what you make in Pure Data should sound the same in Pd++ or Pd4P3, theoretically.  The syntax is also the same between Pd++ and Pd4P3, so what you write in Processing using this library should be able to be copied and pasted to a C++ project, like a JUCE plugin for example, with a few minor alterations.  This way you can test out your ideas quickly in Pure Data, implement a prototype in Processing and then easily deploy the same code to an audio plugin format.  There are obviously a few more steps to actually accomplish this but that would be the workflow.

The backend of Pd4P3 uses the Java Sound API with the option of JPortAudio for Win/MacOS.  There are some latency issues with JPortAudio and MacOS I am still trying to figure out, but both JPortAudio and the Java Sound API work fine in Windows 10.  

The classes in Pd4P3 function like most Java classes, there is input to the class methods, like a frequency, and output, a sine wave.  There is nothing special to the signal chain, the output or return value of every signal object, with a few exceptions like FFT, is a double precision number.  You can add/subtract/multiply/divide these numbers with other objects and make complex processes/synthesizers/etc.  Unlike Java Sound or JSyn (which is still awesome btw), there are no abstract concepts like Mixers, Lines, Ports, Circuits, Synthesizers, Instruments, etc.  Pd4P3 is always just numbers, just like in Pure Data, and you can deal with those numbers how you like.  

# Pure Data to Pd4P3 object table
These are the Pd objects emulated in Pd4P3.
| Class    |   Pd Object |
 --------- | ------------ 
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
ReadSoundFile | [readsf~]*
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
WriteSoundFile | [writesf~]*
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

*Pd objects [readsf~] and [writesf~] are currently in alpha and not fully tested on all platforms. 

What about [adc~] and [dac~]?  The PdAlgorithm abstract class handles input and output.  You will see a method called `runAlgorithm(double in1, double in2)` the arguments represent the input from the microphone(s) and the public members `outputL` and `outputR` represent the output to the system.  

Otherwise everything else in Pd can be easily implemented using standard Java methods or syntax, like math (+ - * /) or Math.sqrt, or basic logic used in [sel], [moses], [route] using if or switch statements.  Any questions just contact the author: robertesler.

# Build for the Raspberry Pi
Since the Pi OS is a version of linux you can build the dynamic library, or .so, using the makefile provided by the Pd++ repository. 
1. Go to: https://bitbucket.org/resler/pd/wiki/Home and clone the Pd++ library in a separate folder. 
2. Navigate to ../Pd++/ 
3. In the Makefile you will see the line: `/usr/lib/jvm/java-1.11.0-openjdk-amd64/include/`, change the `java-1.11.0-openjdk-amd64` to whatever version of java that is installed for your OS, on mine I had to change it to `java-11-openjdk-armhf`.
4. Type `make`  
5. This will create a libpdplusplusTest.so in the /build folder.  Copy it to your Pd4P3/library folder in your /home/pi/sketchbook/libraries/.
6. Open Processing and open a Pd4P3 example to test the build was successful.  

# Build Java Library for Processing 3
If you wanted to make edits to the Java code or add your own classes you could re-build the library easily:

1. Download or clone this repository.
2. Download Ant (https://ant.apache.org/bindownload.cgi) and install
3. Navigate to the repository home folder using the Command Line
4. Type: `ant`
5. Then type: `ant install`, this makes a Processing-ready library dummy folder and a .zip file in the directory just above the repository.
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

STEP 9. In the File system options, for From directory, browse to and select the "Pd4P3/src" folder. Click the src's checkbox; this imports its resources (Java class sources) to your project. Click Finish.

STEP 10. In the com.pdplusplus package, open up the classes and navigate to the Main.java

STEP 11. Double-click on Main.java; this is where the driver, or 
public static void main(String[] args)
lives. 

STEP 12.  Edit the void runAlgorithm() method in the MyMusic class to begin writing DSP code.
