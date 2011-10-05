function [f] = addBinaryLarmGeometry(treenode, parent, vbe, varargin)
defaults.nbins = 10;
opts = propval(varargin, defaults);

pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));

n1 = size(pts1,2);
n2 = size(pts2,2);

%% feat 1: length of arm
D = sqrt(XY2distances(pts1',pts2'));

%trainingset arm length info:
armlens = loadvar('arm_lengths_for_contours.mat','larm');
scale  = (treenode.dims([2 1])./treenode.imgdims([2 1]))';
minarmlength = armlens.minarmlength*mean(scale);
maxarmlength = armlens.maxarmlength*mean(scale)*1.25;

NBINS = 5;
idx = find(vbe);
rawvals = D(idx);
[fnz fbins] = fastdiscretize(rawvals,NBINS,0,maxarmlength);
f_armlen = sparse(idx, fbins, true, size(pts1,2)*size(pts2,2), NBINS);


f = f_armlen;

0;
