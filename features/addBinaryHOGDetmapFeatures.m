function [f] = addBinaryHOGDetmapFeatures(treenode, parent, valid_binary_inds, datadir)

%% get all-pairs uv

pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));

n1 = size(pts1,2);
n2 = size(pts2,2);


% pts2rep = reshape(pts2(1:2,:), [2, 1, n2]);
% pts2rep = repmat(pts2rep, [1, n1, 1]);
% pts1rep = repmat(pts1(1:2,:), [1, 1, n2]);
% ptsdiff = pts1rep - pts2rep;
% uv = reshape(ptsdiff, [2 n1*n2]);
% uv = bsxfun(@times,double(uv), 1./sqrt(sum(uv.^2)));

%simpler, stolen from ipdm.m's efficient all-pairs L1 distance computation:
UV = (bsxfun(@minus,reshape(pts1(1:2,:)',[n1,1,2]),reshape(pts2(1:2,:)',[1,n2,2])));
uv = [vec(UV(:,:,1))'; vec(UV(:,:,2))'];
uv = bsxfun(@times,double(uv), 1./sqrt(sum(uv.^2)));


%% quantize uv to an angular bin in order to index into detmap:
% angles = get_articulated_angles(24);
% uvangles = dir2angle(uv);
% angles = [-pi angles];
% angdiff = bsxfun(@minus, angles', uvangles);
% [mindiff bin] = min(abs(angdiff));
% bin = bin-1;
% bin(bin==0) = numel(angles)-1;

bin = direction2bin(uv,get_articulated_angles(24));

%%
if ~isfield(treenode,'valid_binary_inds')
    treenode.valid_binary_inds = ones(n1,n2);
end

%%

if strcmp(treenode.name(2:end),'uarm') || strcmp(parent.name(2:end),'hand')
    targname = treenode.name;
    
    imat = repmat(pts1(1,:)', 1, n2);
    jmat = repmat(pts1(2,:)', 1, n2);
    
else
    targname = parent.name;
    
    imat = repmat(pts2(1,:), n1, 1);
    jmat = repmat(pts2(2,:), n1, 1);
end

%%
[~,filestem] = fileparts(treenode.imgfile);
filepath = sprintf('%s/cps-features/%s_hog_detmaps.mat',datadir,filestem);
hoginfo = load(filepath);
hoginfo = flip_larm_rarm_hoginfo(hoginfo);

idx = find(strcmp(targname,{hoginfo.parts.name}));

detmap = (hoginfo.parts(idx).detmap);

%%
det_ind = sub2ind(size(detmap), double(imat(:)), double(jmat(:)), double(bin(:)));

%%
det_scores = detmap(det_ind);

%%
bininfo = loadvar('hog-discretization-info.mat');
bi = bininfo.(targname);

nbins = 10;
vbeidx = find(valid_binary_inds);
[fb bins] = fastdiscretize(det_scores(vbeidx), nbins,bi.minval,bi.maxval);
f = sparse(vbeidx, bins, true, n1*n2, nbins);



