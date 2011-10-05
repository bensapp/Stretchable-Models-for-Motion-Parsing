function [f] = addBinaryFlowFGFeatures(treenode, parent, valid_binary_inds, datadir)

%% get all-pairs uv

pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));

n1 = size(pts1,2);
n2 = size(pts2,2);

%% TODO: only load this once (outside this fcn) instead of 4 times
[~,filestem] = fileparts(treenode.imgfile);
filepath = sprintf('%s/flow/%s.mat',datadir,filestem);
flowmag = loadvar(filepath,'fmcropped');
flowmag = imresize(flowmag,treenode.dims(1:2),'bilinear');
flow_smooth = blurimg(flowmag, 3);

%% this is pretty much the slowest way to do it:
F = zeros(size(valid_binary_inds));
[indsi,indsj] = find(valid_binary_inds);
alphas = linspace(0,1,10);
% tic
for k=1:length(indsi)
    i=indsi(k);
    j=indsj(k);
    
    p1 = pts1(1:2,i);
    p2 = pts2(1:2,j);
    v = p1-p2;
    pp = round(bsxfun(@plus,p2,bsxfun(@times,v,alphas)));
    inds = sub2ind(treenode.dims(1:2),pp(2,:),pp(1,:));
    
    F(i,j) = mean(flow_smooth(inds));
    
end
% toc
0;
%%

nbins = 10;
vbeidx = find(valid_binary_inds);
[fb bins] = fastdiscretize(F(vbeidx), nbins,0,1);
f = sparse(vbeidx, bins, true, n1*n2, nbins);



