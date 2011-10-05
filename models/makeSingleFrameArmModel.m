function [treenodes] = makeSingleFrameArmModel(armstate_infos, varargin)
% assumes unary features are already there

% BY DEFAULT, the LEFT ELBOW IS ROOT
defaults.root = 'llarm';
defaults.num_parts = numel(getArmPartName);
opts = propval(varargin, defaults);

rootid = getArmPartID(opts.root);

treenodes = armstate_infos;

% clear all parents and children
for i = 1:numel(treenodes)
    treenodes(i).parent = [];
    treenodes(i).children = [];
end

% add edges between arms
for i = 1:numel(treenodes)

    if treenodes(i).partid == rootid
        treenodes(i).parent = 0;
    end
    
    treenodes(i).children = floor(i./opts.num_parts) + getCanonicalChildren(treenodes(i).partid);
    for j = treenodes(i).children
        treenodes(j).parent = i;
    end
end

return;

% add features given the previous connections 
timeleft;
for i = 1:numel(treenodes)
    timeleft(numel(treenodes));

    % add binary features
    if treenodes(i).parent
        treenodes(i) = ...
            binary_features_pair(treenodes(i), treenodes(treenodes(i).parent));
    else
        treenodes(i).binary_features = [];
        treenodes(i).valid_binary_inds = [];
    end
end    

function [tn] = binary_features_pair(child, parent)



