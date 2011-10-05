******************************************************************************
Cascaded Pictorial Structures code
Ben Sapp, Alex Toshev & Ben Taskar
version 1, September 20, 2010

from the paper 
Cascaded Models for Articulated Pose Estimation. ECCV2010
http://www.seas.upenn.edu/~bensapp/papers/eccv2010_cps.pdf
for questions/comments, email me at bensapp@cis.upenn.edu
*********************************************************************************

------------------------------------------------
Quick Start
------------------------------------------------
To run on a new image, simply use cps_demo.m, setting opts.imgfile and opts.outputdir as desired.

The input images are intended to be 333x370 pixel images of people roughly localized by an upper body detector.  We use the bounding boxes provided by Eichner et al’s BMVC09 work.  More recently, they have developed a more robust upper body person detector, which can be found here:
http://www.vision.ee.ethz.ch/~calvin/calvin_upperbody_detector/

------------------------------------------------
Results
------------------------------------------------
If you run cps_demo.m on every image in the images/Buffy_v2.1 dataset so that the *_final_prediction.mat files are all saved in a directory, you can evaluate the test set performance by running cps_eval_dataset.m

You should get the following output:
torso: 99.57
ruarm: 93.62
rlarm: 65.11
luarm: 90.21
llarm: 63.83
head: 98.72
total: 85.18

and for PASCAL (images in images/PASCAL):
torso: 100.00
ruarm: 80.28
rlarm: 53.61
luarm: 82.78
llarm: 54.17
head: 99.17
total: 78.33

These numbers are slightly different from the paper because a few things have changed to make the code cleaner and significantly faster.

------------------------------------------------
Processing Pipeline w/ Timing
------------------------------------------------
For a single input image of resolution 333x370 pixels, here is a breakdown of the steps and time each step takes:

1. compute HoG part detector detmaps: ~1m20s
2. applying cascade of coarse2fine models: <5 seconds
3. computing richer features
    a. pb+ncut: ~2m45s
    b. color models: ~7 seconds
    c. rest of feature computation: ~25 seconds
4. evaluating gentleboost pairwise potential model: ~30 seconds
5. final prediction inference: <1 second
TOTAL: ~5m15s

This was evaluated on this machine:
Linux 2.6.31.5-0.1-default #1 SMP 2009-10-26 15:49:03 +0100 x86_64 x86_64 x86_64 GNU/Linux
Intel(R) Xeon(R) CPU E5450  @ 3.00GHz (w/ 8 cpus)

Please note that this code is a 'research' release.  There are many obvious ways to speed it up (e.g., not saving intermediate steps to disk; mex'ing slow parts), but it is useful for debugging and analysis.

------------------------------------------------------------------------
Differences from paper implementation
------------------------------------------------------------------------
This implementation is slightly different than the paper version:

- Coarse-to-fine pruning: Rather than a fixed alpha = 0 for every part (ie., pruning the mean max-marginal), we now learn a separate alpha for each part. During training, we set all alphas to 0 (learning to push the groundtruth score above average), and set the run-time alphas using cross-validation to keep 95% of the groundtruth.  This framework still yields a convex learning formulation, and allows us to have more flexible pruning - more aggressive on easier parts.
- Features:  We also include an ncut embedding distance feature in the spirit of our pairwise color chi^2 distance feature.  This embedding feature is a cosine distance between the average vector over the rectangular support of each limb in the embedding space (30 dimensional corresponding to the top 30 eigenvectors).   Also, the HoG part detectors are faster (evaluated fewer rounds of boosting), but less accurate.

------------------------------------------------
Compiling & MEX Files
------------------------------------------------
All mex files (mex_*.cpp) are currently compiled for 64-bit Linux:
Linux 2.6.31.5-0.1-default #1 SMP 2009-10-26 15:49:03 +0100 x86_64 x86_64 x86_64 GNU/Linux

If you also use 64-bit Linux, it should just work.  Otherwise, you’ll need to compile all the misc. mex files.  Some details:
- For 3rd party tools (e.g., ncut_multiscale_1_5, ann_mwrapper), see individual instructions within the ./thirdparty/* folder
- OpenCV is a special case - the version supplied has been modified by me to be more friendly w.r.t. logging and saving the boosted classifiers.  So it’s important to use the source code provided, and not a different version.  The src is in ./thirdparty/OpenCV-2.0.0, and compiled libs are in ./thirdparty/opencv

