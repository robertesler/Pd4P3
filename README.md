# Pd4P3
A java implementation of the Pd++ library, a C++ native library of Pure Data's signal objects.  This library is designed to eventually be a library option in Processing 3. 

# Pd++
Pd++ is a C++ library based on the signal objects of Pure Data.  More information can be found here: https://bitbucket.org/resler/pd/src/master/

# Versions (Win)
This version of the library right now only works on Windows 10.  The .dll in the /lib folder are built for Windows.  If you want to use this on MacOS or Linux then for now you would have to build Pd++, portaudio and jPortAudio for your architecture.  This will be updated soon to include MacOS and Linux builds. 

# Using Eclipse
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
