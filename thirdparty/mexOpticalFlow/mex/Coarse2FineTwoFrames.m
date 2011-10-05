% function to compute dense optical flow field in a coarse to fine manner
%
% usage:
%
% [vx,vy,warpI2]=Coarse2FineTwoFrames(im1,im2);
% [vx,vy,warpI2]=Coarse2FineTwoFrames(im1,im2,para);
%
% im1, im2: two frames with the same dimension
% para (optional): the argument for optical flow
%     para(1)--alpha (0.01), the regularization weight
%     para(2)--ratio (0.75), the downsample ratio
%     para(3)--minWidth (30), the width of the coarsest level
%     para(4)--nOuterFPIterations (15), the number of outer fixed point iterations
%     para(5)--nInnerFPIterations (1), the number of inner fixed point iterations
%     para(6)--nCGIterations (40), the number of CG iterations
%
% Ce Liu
% Dec, 2009
% celiu@mit.edu
