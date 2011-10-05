function [max_state_seq,submodels] = runEnsembleInferenceSingleFrameExact(armstate_infos,edgeInfo,w,submodels)
%%
% ENSEMBLE INFERENCE
% timeleft;
% fprintf('Inference in ensemble: ');

for j = 1:numel(submodels)
    tic
    %     timeleft(numel(submodels));
    
    tree = makeArmTrackingTreeModel(armstate_infos, submodels(j));
    tree = insertPrecomputedFeatures(tree, edgeInfo);
    
    
    % hit w with phi
    tree = scoreUnaryCliques(tree, w(j));
    tree = scorePairwiseCliques(tree, w(j));
    
    
    % run message passing
    [submodels(j).max_state_seq, submodels(j).max_marginals, ~, submodels(j).fwd_bwd_msgs] = ...
        ps_model_max_inference_2clique_sparse_edges(tree);
    [u,a,uframes] = unique([tree.currframe]);
    submodels(j).fwd_bwd_msgs = setfield2(submodels(j).fwd_bwd_msgs,'frame',uframes);
    tree = setfield2(tree,'frame',uframes);
    tree = setfield2(tree,'ind',1:length(tree));
    submodels(j).tree = tree;
    toc
end


%%

max_state_seq = singleFrameJunctionTree(submodels);


