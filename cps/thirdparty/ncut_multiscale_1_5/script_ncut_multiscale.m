%<MARKER v48752.jpg>
% script_ncut_multiscale
% basic demo to illustrate Multiscale Normalized Cuts Segmentation Code 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                  %
%   Multiscale Normalized Cuts Segmentation Code   %
%                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Authors: Timothee Cour, Florence Benezit, Jianbo Shi
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


% # of segments requested
nsegs=30;

% input image
image=imread2('v48752.jpg');
image=rgb2gray(image);
[p,q,r]=size(image);

disp(['image size : ',mat2str([p,q,r]) ]);
nbPixels=p*q;
disp(['number of pixels : ',num2str(nbPixels) ]);

disp('starting multiscale segmentation...');

[classes,X,lambda,Xr,W,C,timing] = ncut_multiscale(image,nsegs);
figure;
imagesc(classes);
axis image

disp('The demo is finished.');

