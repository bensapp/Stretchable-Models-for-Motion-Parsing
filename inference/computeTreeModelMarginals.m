function [treenodes, max_state_seq, tru_state_seq, max_marginals, ...
    max_counts, thresh, truScore, meanScore, maxScore] = ...
    computeTreeModelMarginals(treenodes, w, alpha, do_initialize)

% score unary terms
treenodes = scoreUnaryCliques(treenodes, w);

% score and compute max marginals
treenodes = scorePairwiseCliques(treenodes, w);

%% tracking setting: hand-intialize the first frame with groundtruth, see how well it tracks
if do_initialize
    
    maxval = sum(vec(cellfun(@(x)(max(x(:))),{treenodes.log_binary_clique},'uniformoutput',false)));
    maxval = maxval + sum(cellfun(@max,{treenodes.log_unary_clique}));
    idx = find([treenodes.currframe]==treenodes(1).currframe);
    for i=1:length(idx)
        %find closet statept to gtpt
        gtpt = ind2pts(treenodes(idx(i)).dims,treenodes(idx(i)).gt_state);
        statepts = ind2pts(treenodes(idx(i)).dims,treenodes(idx(i)).states);
        gtstateidx = argmin(sum(abs(bsxfun(@minus,double(statepts),double(gtpt)))));
        
        % set the unary score for the gt part to some ridiculously high
        % value
        treenodes(idx(i)).log_unary_clique(gtstateidx) = 1.1*(1+maxval);
    end
    
   0; 
end

%%

% run message passing
[max_state_seq, max_marginals, max_counts] = ...
    ps_model_max_inference_2clique_sparse_edges(treenodes);

% compute mean, max score etc.
maxScore = getAssignmentScore(treenodes, max_state_seq);


has_truth = false;
truScore = nan; 
tru_state_seq = [];

meanScore = getMeanMMScore(treenodes, max_marginals);
thresh = alpha*maxScore + (1-alpha)*meanScore;


if nargout==1
    treenodes = bundle(treenodes,max_state_seq,tru_state_seq,...
        max_marginals,max_counts,thresh,truScore,meanScore,maxScore);
end

