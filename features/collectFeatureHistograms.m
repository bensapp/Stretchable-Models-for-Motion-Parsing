function [feats feats_gt] = collectFeatureHistograms(clips, opts)

feats.unary = cell(6,1);
feats.binary = cell(6,6);

collect_edge = true;
feats_gt = feats;

for i = 1:numel(clips)
    if collect_edge
        fprintf('loading data: ');
        tic; [armstate_infos edgeInfo] = loadClipStatesEdges(clips(i), opts); toc;
    else
        armstate_infos = loadClipStatesEdges(clips(i), opts);
    end
    
    % go through all armstate_infos and collect unary features
    timeleft;
    for j = 1:numel(armstate_infos)
        timeleft(numel(armstate_infos));
        
        p = armstate_infos(j).partid;
        
        f = armstate_infos(j).unary_features;
        
        idx = find(armstate_infos(j).states ~= armstate_infos(j).gt_state);
        gtidx = find(armstate_infos(j).states == armstate_infos(j).gt_state);
        
        feats.unary = collect(feats.unary, p, sum(f(idx,:)));
        feats_gt.unary = collect(feats_gt.unary, p, full(f(gtidx,:)));
    end
    
    if collect_edge
        timeleft;
        for j = 1:numel(edgeInfo.edges)
            timeleft(numel(edgeInfo.edges));
            
            e = edgeInfo.edges(j);
            par = armstate_infos(e.par_idx);
            par_ind = find(par.states==par.gt_state);
            child = armstate_infos(e.child_idx);
            child_ind = find(child.states==child.gt_state);
            
            gt_ind = sub2ind(size(e.valid_binary_inds), child_ind, par_ind);
            
            pind = sub2ind([6 6], par.partid, child.partid);
            
            assert(sum(double(e.binary_features(gt_ind,:))) > 0);
            
            feats_gt.binary = collect(feats_gt.binary, pind, double(e.binary_features(gt_ind,:)));
            feats.binary = collect(feats.binary, pind, sum(e.binary_features));
        end
    end
    
end

function [f] = collect(f, i, x)

if isempty(f{i}) f{i} = x;
else f{i} = f{i} + x;
end
    