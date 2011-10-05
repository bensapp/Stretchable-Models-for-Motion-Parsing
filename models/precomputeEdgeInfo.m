function [edgeInfo] = precomputeEdgeInfo(armstate_infos,datadir)
%%

frames = [armstate_infos.currframe];
partids = [armstate_infos.partid];

[framerange, frameidx, tidx] = unique(frames);

lookupEdge = zeros(numel(armstate_infos));
edges = [];

current_edge = 1;

%%
fprintf('precomputing edge features: ');
timer = CTimeleft(numel(framerange));
for t = 1:numel(framerange)    
    timer.timeleft;
    % first add edges from shoulder->elbow->hands
    addEdge('luarm', 0, 'llarm', 0);
    addEdge('llarm', 0, 'lhand', 0);
 
    addEdge('ruarm', 0, 'rlarm', 0);
    addEdge('rlarm', 0, 'rhand', 0);

    meminfo = whos('edges');

    % add within-frame color consistency edges
    addEdge('luarm', 0, 'ruarm', 0);
    addEdge('llarm', 0, 'rlarm', 0);
    addEdge('lhand', 0, 'rhand', 0);
    
    % add time tracking edges
    addEdge('luarm', 0, 'luarm', 1);
    addEdge('llarm', 0, 'llarm', 1);
    addEdge('lhand', 0, 'lhand', 1);
    
    addEdge('ruarm', 0, 'ruarm', 1);
    addEdge('rlarm', 0, 'rlarm', 1);
    addEdge('rhand', 0, 'rhand', 1);
    
    meminfo = whos('edges');
    memusage = meminfo.bytes./2^20./numel(edges);
%     fprintf('%g MB per edge = %g total projected', memusage, memusage*13*numel(framerange));
end

edgeInfo = bundle(lookupEdge, edges);


% nested function for adding edges
    function addEdge( par_name, par_offset, child_name, child_offset )
        
        
        par_t = t+par_offset;
        child_t = t+child_offset;
        
        % find the indices of each child etc.
        par_idx = find(tidx==par_t & partids == getArmPartID(par_name));
        child_idx = find(tidx==child_t & partids == getArmPartID(child_name));
        
        if isempty(par_idx) || isempty(child_idx)
            return;
        end
        assert(numel(par_idx)==1 && numel(child_idx)==1);
        
        [binary_features, valid_binary_inds binary_featinds] = computeBinaryFeatures(armstate_infos(child_idx), ...
            armstate_infos(par_idx),datadir);
        
        % ensure logical and sparse
        if ~islogical(valid_binary_inds), valid_binary_inds = valid_binary_inds>0; end
        if ~issparse(valid_binary_inds), valid_binary_inds = sparse(valid_binary_inds); end

        % also store binary features transpose
        n1 = size(valid_binary_inds,1);
        n2 = size(valid_binary_inds,2);
            
        [r,c] = ind2sub2([n2 n1],1:(n1*n2));
        inds_transpose = sub2ind2([n1 n2],c,r);
        
        binary_features_transpose = binary_features(inds_transpose,:);

        flip_valid = false;
        if mean(valid_binary_inds(:)) > 0.5
            valid_binary_inds = ~valid_binary_inds;
            flip_valid = true;
        end
        
        e = bundle(binary_features,binary_features_transpose, ...
            valid_binary_inds,par_name,child_name,par_idx,child_idx, flip_valid,binary_featinds);
        
        if isempty(edges) edges = e; 
        else edges(current_edge) = e;
        end
        
        lookupEdge(child_idx, par_idx) = current_edge;
        lookupEdge(par_idx, child_idx) = -current_edge;
        
        current_edge = current_edge + 1;
    end
end

