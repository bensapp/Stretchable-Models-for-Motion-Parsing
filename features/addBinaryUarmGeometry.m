function [f] = addBinaryUarmGeometry(treenode, parent, vbe, varargin)
defaults.nbins = 10;
opts = propval(varargin, defaults);

pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));

n1 = size(pts1,2);
n2 = size(pts2,2);

%% feat 1: length of arm
D = sqrt(XY2distances(pts1',pts2'));

%trainingset arm length info:
armlens = loadvar('arm_lengths_for_contours.mat','uarm');
scale  = (treenode.dims([2 1])./treenode.imgdims([2 1]))';
minarmlength = armlens.minarmlength*mean(scale);
maxarmlength = armlens.maxarmlength*mean(scale);

idx = find(vbe);
rawvals = D(idx);
[fnz fbins] = fastdiscretize(rawvals, opts.nbins,minarmlength,maxarmlength);
f_armlen = sparse(idx, fbins, true, size(pts1,2)*size(pts2,2), opts.nbins);

%% feat 2: dot prod with y axis
UV = (bsxfun(@minus,reshape(pts1(1:2,:)',[n1,1,2]),reshape(pts2(1:2,:)',[1,n2,2])));
uv = [vec(UV(:,:,1))'; vec(UV(:,:,2))'];
uv = bsxfun(@times,double(uv), 1./(eps+sqrt(sum(uv.^2))));
dprod = uv'*[0;1];
%from [-1,1] --> [0,1]
dprod = (dprod+1)/2;

idx = find(vbe);
rawvals = dprod(idx);
[fnz fbins] = fastdiscretize(rawvals, opts.nbins);
f_yaxis = sparse(idx, fbins, true, size(pts1,2)*size(pts2,2), opts.nbins);

f = [f_armlen f_yaxis];

0;

%%
return

figure(1);
imsc(img1);

hold on;
myplot(pts1, 'ow');
myplot(pts2, 'xb');
hold off;



