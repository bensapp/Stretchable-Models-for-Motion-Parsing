function [flow,imflow] = c2f_optical_flow(img1,img2)
max_height = 240;
img1 = imresize(img1,[max_height NaN],'bilinear');
img2 = imresize(img2,[max_height NaN],'bilinear');

% set optical flow parameters (see Coarse2FineTwoFrames.m for the definition of the parameters)
alpha = 0.02;          
ratio = 0.75;
minWidth = 30;
nOuterFPIterations = 20;
nInnerFPIterations = 1;
nCGIterations = 50;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nCGIterations];

% this is the core part of calling the mexed dll file for computing optical flow
% it also returns the time that is needed for two-frame estimation
[vx,vy,warpI2] = Coarse2FineTwoFrames(img1,img2,para);

clear flow;
flow(:,:,1) = vx;
flow(:,:,2) = vy;

if nargout == 2
    imflow = flowToColor(flow);
end
