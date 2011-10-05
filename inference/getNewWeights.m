function [w] = getNewWeights(clips, submodels, opts)

tic; [armstate_infos edgeInfo] = loadClipStatesEdges(clips(1), opts); toc

tic
for j = 1:numel(submodels)    

    tn = makeArmTrackingTreeModel(armstate_infos, submodels(j));
    tn = insertPrecomputedFeatures(tn, edgeInfo);

    w(j) = initWeights(tn,opts);
end
elapsed = toc;
dispf('average time: %g', elapsed/numel(submodels));