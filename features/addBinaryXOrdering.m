function [f] = addBinaryXOrdering(treenode, parent, vbe, varargin)
defaults.nbins = 10;
opts = propval(varargin, defaults);


pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));

dx = (bsxfun(@minus,reshape(pts1(1,:)',[size(pts1,2),1,1]),reshape(pts2(1,:)',[1,size(pts2,2),1])));

%normalize to [0 1]
dx = (dx/treenode.dims(2)+1)/2;

idx = find(vbe);
rawvals = dx(idx);

[fnz fbins] = fastdiscretize(rawvals, opts.nbins);
f = sparse(idx, fbins, true, size(pts1,2)*size(pts2,2), opts.nbins);

%%
return

figure(1);
imsc(img1);

hold on;
myplot(pts1, 'ow');
myplot(pts2, 'xb');
hold off;



