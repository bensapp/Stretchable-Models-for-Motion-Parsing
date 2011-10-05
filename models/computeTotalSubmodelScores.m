function [info] = computeTotalSubmodelScores(armstate_infos, edgeInfo, submodels, w)

scores = [];
edgeScores = [];

timeleft;
for j = 1:numel(submodels)
    timeleft(numel(submodels));
    
    tn = makeArmTrackingTreeModel(armstate_infos, submodels(j));
    tn = insertPrecomputedFeatures(tn, edgeInfo);    
   
    % score unary terms
    tn = scoreUnaryCliques(tn, w(j));

    % score and compute max marginals
    tn = scorePairwiseCliques(tn, w(j));

    if isempty(scores)
        [scores edgeScores] = tallyComputedScores(tn,edgeInfo);
    else
        [scores edgeScores] = tallyComputedScores(tn,edgeInfo,scores,edgeScores);
    end
    
    [max_state_seq, max_marginals, max_counts] = ...
        ps_model_max_inference_2clique_sparse_edges(tn);
    
    maxvals(j) = max(max_marginals(1).max_marginal);
    
    guesses(j,:) = [max_state_seq.state_ind];
end

info = bundle(scores,edgeScores,guesses);
