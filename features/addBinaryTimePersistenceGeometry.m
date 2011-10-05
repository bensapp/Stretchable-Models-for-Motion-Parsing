function [f vbe rawvals] = addBinaryTimePersistenceGeometry(treenode, parent, varargin)

defaults.nbins = 10;
opts = propval(varargin, defaults);

pts1 = ind2pts(treenode.dims, treenode.states);
pts2 = ind2pts(parent.dims, parent.states);
pts1 = double(pts1(1:2,:));
pts2 = double(pts2(1:2,:));

%scale points to be in [0,1]
pts1 = bsxfun(@times, pts1, 1./treenode.dims([2 1])');
pts2 = bsxfun(@times, pts2, 1./parent.dims([2 1])');



D = sqrt(XY2distances(pts1',pts2'));
vbe = sparse(D <= 40/80);
% vbe = ensureGTEdge(vbe, treenode, parent);

idx = find(vbe);
rawvals = D(idx);
rawvals = scale01(rawvals);

[fnz fbins] = fastdiscretize(rawvals, opts.nbins);
f = sparse(idx, fbins,true, size(pts1,2)*size(pts2,2), opts.nbins);


%%
return

figure(1);
imsc(img1);

hold on;
myplot(pts1, 'ow');
myplot(pts2, 'xb');
hold off;



