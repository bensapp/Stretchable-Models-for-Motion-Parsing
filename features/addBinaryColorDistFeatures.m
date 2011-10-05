function [f,rawvals] = addBinaryColorDistFeatures(treenode, parent, vbe, method, varargin)

defaults.nbcolors = 32;
defaults.nbins = 10;
defaults.bsize = 30;

opts = propval(varargin, defaults);
%%
img1 = imread(treenode.imgfile);
img2 = imread(parent.imgfile);
%% compute and scale points to images
pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));


pts1fullframe = mapPoints2NewDims(pts1,treenode.dims,[size2(img1,[1 2]) 1]);
pts2fullframe = mapPoints2NewDims(pts2,parent.dims,[size2(img2,[1 2]) 1]);

D = color_track_sparse_pts(pts1fullframe, pts2fullframe, vbe, img1, img2, opts.bsize, opts.nbcolors, method);

idx = find(vbe);
rawvals = D(idx);
rawvals = scale01(rawvals);

[fnz fbins] = fastdiscretize(rawvals, opts.nbins);
f = sparse(idx, fbins, true, size(pts1,2)*size(pts2,2), opts.nbins);



