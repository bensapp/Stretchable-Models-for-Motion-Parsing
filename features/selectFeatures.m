function [nodeInfo edgeInfo] = selectFeatures(nodeInfo,edgeInfo,featuresel);


if isempty(featuresel), return; end

%% node feats
for i=1:length(nodeInfo)
    
    fkeep = intersect(fields(nodeInfo(i).featinds),featuresel);
    fdiscard = setdiff(fields(nodeInfo(i).featinds),featuresel);
    if numel(fdiscard) > 0
        dispf('node fidx discarded: %s', cell2str(fdiscard));
    end
    
    fidx = [];
    for k=1:length(fkeep)
        fidx = [fidx nodeInfo(i).featinds.(fkeep{k})];
    end
    fidx = sort(fidx);

    if isempty(fidx)
        nrows = size(nodeInfo(i).unary_features,1);
        nodeInfo(i).unary_features = sparse(nrows,1,false);
    else
        nodeInfo(i).unary_features = nodeInfo(i).unary_features(:,fidx);
    end
    
    %remove featinds lest we think they're still valid (TODO: remake them correctly instead of just
    %deleting)
    nodeInfo(i).featinds = [];
end

%% edge feats
for i=1:length(edgeInfo.edges)
    
    fkeep = intersect(fields(edgeInfo.edges(i).binary_featinds),featuresel);
    fdiscard = setdiff(fields(edgeInfo.edges(i).binary_featinds),featuresel);
    
    if numel(fdiscard) > 0
        dispf('edge fidx discarded: %s', cell2str(fdiscard));
    end
    
    fidx = [];
    for k=1:length(fkeep)
        fidx = [fidx edgeInfo.edges(i).binary_featinds.(fkeep{k})];
    end
    fidx = sort(fidx);

    
    if isempty(fidx)
        nrows = size(edgeInfo.edges(i).binary_features,1);
        edgeInfo.edges(i).binary_features = sparse(nrows,1,false);
        edgeInfo.edges(i).binary_features_transpose = sparse(nrows,1,false);
    else
        edgeInfo.edges(i).binary_features = edgeInfo.edges(i).binary_features(:,fidx);
        edgeInfo.edges(i).binary_features_transpose = edgeInfo.edges(i).binary_features_transpose(:,fidx);
    end
    
    
    
    %remove featinds lest we think they're still valid (TODO: remake them correctly instead of just deleting)
    edgeInfo.edges(i).binary_featinds = [];
end