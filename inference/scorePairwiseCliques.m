function [treenodes] = scorePairwiseCliques(treenodes, w)
% scores based on binary features computed between a given node and its
% parent.
FIXED_BAD_VAL = -50;
for i=1:length(treenodes)

    % parent == 0 --> no pairwise potential
    if treenodes(i).parent == 0, continue, end

    parent = treenodes(treenodes(i).parent);
        
    nstates = length(treenodes(i).states);
    npstates = length(parent.states);

    % get the binary weights: between one part and another
    binary_weights = w.binary_w{parent.partid, treenodes(i).partid};
    
    % ensure weights are sparse 
    assert(issparse(treenodes(i).binary_features));

    % compute actual scores and reshape to N X M matrix, where
    % N = # of our states
    % M = # of our parent's states
    
    %scores = treenodes(i).binary_features*binary_weights;
    scores = mex_sparse_binary_ddot(treenodes(i).binary_features, binary_weights);
    
    %assert(all(scores)==all(scores2));
    
%     treenodes(i).log_binary_clique = full(reshape(scores, nstates, npstates));
%     treenodes(i).log_binary_clique(~treenodes(i).valid_binary_inds) = FIXED_BAD_VAL;

    treenodes(i).log_binary_clique = reshape(scores, nstates, npstates);
    

end