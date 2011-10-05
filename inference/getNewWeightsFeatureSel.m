function [w] = getNewWeightsFeatureSel(clips, submodels, featsel, opts)

tic; [armstate_infos edgeInfo] = loadClipStatesEdges(clips(1), opts); toc
armstate_infos = fixFeatureInds(armstate_infos);

tic
for j = 1:numel(submodels)    

    tn = makeArmTrackingTreeModel(armstate_infos, submodels(j));
    tn = insertPrecomputedFeatures(tn, edgeInfo, featsel);

    if opts.tie_weights
        if ~exist('w','var')
            w = initWeights(tn,opts);
        else
            w = initWeights(tn,opts,w);
        end
    else
        w(j) = initWeights(tn,opts);
    end
end
elapsed = toc;
dispf('average time: %g', elapsed/numel(submodels)); 


%{
    %feature selection:
    fkeep = intersect(fields(treenodes(j).featinds),featsel);
    fidx = [];
    for k=1:length(fkeep)
        fidx = [fidx treenodes(j).featinds.(fkeep{k})]
    end
    fidx = sort(fidx);
%}
