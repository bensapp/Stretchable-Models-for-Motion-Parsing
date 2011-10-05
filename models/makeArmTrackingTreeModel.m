function [treenodes] = makeArmTrackingTreeModel(armstate_infos, submodel, varargin)
% [treenodes] = makeArmTrackingTreeModel(armstate_infos, submodel, ...)

defaults.num_parts = 6;
opts = propval(varargin, defaults);

rootid = getArmPartID(submodel.root);

treenodes = armstate_infos;

% clear all parents and children
for i = 1:numel(treenodes)
    treenodes(i).parent = [];
    treenodes(i).children = [];
end

% add edges between arms
for i = 1:numel(treenodes)

    % get frame idx (zeroed to zero for computing offsets, 
    %                but zeroed to one for future reference)
    
    tidx = floor((i-1)./opts.num_parts);
    treenodes(i).tidx = tidx+1;
    
    % check for global root
    if treenodes(i).partid == rootid && tidx == 0
        treenodes(i).parent = 0;
    end

    % add temporal tracking children
    if treenodes(i).partid == rootid

        treenodes(i).children = i + opts.num_parts;
       
        if treenodes(i).children > numel(treenodes)
            treenodes(i).children = [];
        end
        
    end

    % add children according to single-frame model
    children = submodel.(treenodes(i).name);
    for j = 1:numel(children)
        treenodes(i).children = [treenodes(i).children tidx*opts.num_parts + getArmPartID(children{j})];
    end

    % set parents
    for j = treenodes(i).children
        % concat, to catch multiple parents for debuggin!!
        treenodes(j).parent = [treenodes(j).parent i];
    end
end