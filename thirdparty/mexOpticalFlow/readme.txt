The C++ package has been successfully compiled in the x64 Windows and x64 Linux. The compiler I used in Windows is Visual Studio, and the compiler in Linux is g++. 

Before compiling, please check project.h file in subfolder "mex". You don't have to do anything if you use Windows. If you use Mac Os or Linux, please comment the line 
#define _Windows
and you should be good to go.

In Matlab, after you configure mex appropriately, change directory to "mex" and run the following command:
 
mex Coarse2FineTwoFrames.cpp OpticalFlow.cpp GaussianPyramid.cpp

Now you should be able to have the dll that is compatible with your OS. Have fun!