function [mmarg_info] = runEnsembleInference(armstate_infos, edgeInfo, w, submodels, opts)

% ENSEMBLE INFERENCE

for j = 1:numel(submodels)
    fprintf('inference in submodel #%d...\n',j);
    tn = makeArmTrackingTreeModel(armstate_infos, submodels(j));
    tn = insertPrecomputedFeatures(tn, edgeInfo); 
    
    if numel(w) == 1
        mmarg_info(j) = computeTreeModelMarginals(tn, w, opts.alpha, opts.do_initialize);
    else
        mmarg_info(j) = computeTreeModelMarginals(tn, w(j), opts.alpha, opts.do_initialize);
    end
    
    % save memory
    mmarg_info(j).treenodes = [];
end
fprintf('Done!\n');