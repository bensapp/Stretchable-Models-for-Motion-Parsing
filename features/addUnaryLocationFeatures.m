function [armstate_infos] = addUnaryLocationFeatures(armstate_infos, varargin)

defaults.coarse_grid = [5 5];
opts = propval(varargin, defaults);

nfeat = prod(opts.coarse_grid);

for i = 1:numel(armstate_infos)
    
    pts = ind2pts(armstate_infos(i).dims, armstate_infos(i).states);
    newpts = mapPoints2NewDims(pts, armstate_infos(i).dims, opts.coarse_grid);
    rawf = pts2ind(opts.coarse_grid, newpts);
    
    f = ind2vecpad(rawf, nfeat, length(rawf))';
    armstate_infos(i).unary_features_raw = [armstate_infos(i).unary_features_raw rawf'];
    armstate_infos(i).unary_features = [armstate_infos(i).unary_features f];
    
    % tack on feature indices
    maxind = maxFeatureInd(armstate_infos(i).featinds);
    armstate_infos(i).featinds.loc = maxind+1:maxind+size(f,2);
end