%<MARKER v48752.jpg>
% script_ncut_multiscale_timing
% demo to show the linear running time of Multiscale Normalized Cuts
% Segmentation
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

% consecutive image sizes (will be computed from those ratios)
imsizeRatios=[0.05,0.1,0.2,0.3,0.4,0.5,0.7,1];
fig1=figure;
title('computation time of W*X operation');
fig2=figure;
title('total computation time of eigensolver');

% for each ratio, resize image and compute ncut_multiscale
for i=1:length(imsizeRatios)
    imagei=imresize(image,imsizeRatios(i));
    [pi,qi,r]=size(imagei);
    disp(['image size : ',mat2str([pi,qi,r]) ]);
    nbPixels=pi*qi;
    disp(['number of pixels : ',num2str(nbPixels) ]);

    disp('press Enter to segment the image...');
    pause;
    
    [classes,X,lambda,Xr,W,C,timing] = ncut_multiscale(imagei,nsegs);
    figure;
    imagesc(classes);
    axis image
    
    % timing information
    computationTime(i).time=timing.A_times_X;
    computationTime(i).timeTotal=timing.total;
    computationTime(i).nbPixels=nbPixels;
    figure(fig1);
    plot([computationTime.nbPixels],[computationTime.time]);
    figure(fig2);
    plot([computationTime.nbPixels],[computationTime.timeTotal]);
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
end

disp('The demo is finished.');

