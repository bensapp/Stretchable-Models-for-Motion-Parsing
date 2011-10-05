
Parsing Human Motion with Stretchable Models ]]. Benjamin Sapp, David Weiss and Ben Taskar. CVPR. June 2011.
Code version 1.0, October 4, 2011. 


!! Download
This project is hosted on github.  To obtain, run the command

$ git clone git://github.com/bensapp/Stretchable-Models-for-Motion-Parsing.git

from a console or download a static copy from 

https://github.com/bensapp/Stretchable-Models-for-Motion-Parsing/zipball/master


!! Usage
To run on a new image, see @@demo_stretchable_model.m@@

The required input is a sequence of video filenames and a list of torso detection boxes; see the example input in @@demo_stretchable_model.m@@.  The code then computes a variety of features, runs the [[Cascaded Pictorial Structures code]], and performs the simplest, most efficient of our tree ensemble inference methods.  See our paper



!! Mex compilation issues

The code makes heavy use of mex and also requires a slightly modified version of OpenCV (easier read/write and status updates in the boosting library).  I have included all source code, but have compiled binaries only for 64 bit linux (hence, *.mexa64 files).  Please ask if you have any difficulties compiling any of the mex files in any other environment.  Also, if you DO compile binaries in other environments (e.g., mexmaci, mexglx, windows), please let me know and I can add them to the download to make it easier for others.

If you're running in a 64 bit linux environment, make sure your LD_LIBRARY_PATH is set to correctly use the OpenCV libs included in @@stretchable-models/cps/thirdparty/OpenCV-2.0.0/lib/@@

You can check this inside matlab using the command '!ldd mex_file.mexa64' for example.


!! Processing Pipeline & Timing
For a video sequence, here is a breakdown of the steps and time each step takes:

*Run Cascaded PS (including HoG detectors, pb, ncut and associated features): ~5 minutes / frame
*Compute optical flow: 15-20 seconds / frame
*Compute additional features, collect all features and discretize: 1 minute / frame and 90MB / frame
*Inference: 1 second / frame

This was evaluated on this machine: 
Linux 2.6.31.5-0.1-default x86_64 GNU/Linux 
Intel(R) Xeon(R) CPU E5450  @ 3.00GHz (w/ 8 cpus)
MATLAB R2010b



