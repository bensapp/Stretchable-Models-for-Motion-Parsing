function [guess ddinfo] = getDDPredictions(clip, w, opts, use_best)

if nargin==3
    use_best = false;
end

filename = armtracking_root('dd_results', ...
    clip.moviename, ...
         sprintf('%08d.mat', clip.examples(1).currframe));
a = load(filename);

% find max primal value

primval = [a.data.realprimval];
dualvals = [a.data.dualval];

[maxprimval bestidx] = max(primval);

dispf('found max primal val: %g, dual %g, at rnd %g\n', ...
    maxprimval, min(dualvals), bestidx);

guesses = a.data(end).guesses;

if use_best
    
    submodels = getSubModelDefs;
    
    %%
    fprintf('loading data: ');
    tic
    [armstate_infos edgeInfo] = loadClipStatesEdges(clip, opts);
    toc
    
    for j =1:numel(submodels)
        tn = makeArmTrackingTreeModel(armstate_infos, submodels(j));
        tn = insertPrecomputedFeatures(tn, edgeInfo);
        
        % score unary terms
        tn = scoreUnaryCliques(tn, w(j));

        % score and compute max marginals
        tn = scorePairwiseCliques(tn, w(j));

        maxstates = guesses(j,:);
        for k =1:numel(tn)
            max_state_seq(k).state_ind = maxstates(k);
        end
        for h = 1:numel(submodels)
            primscores(j,h) = getAssignmentScore(tn, max_state_seq);
        end
    end
    
    [bestprim bestguess] = max(sum(primscores));
    
    dispf('found best prim %g, guess %g\n', bestprim, bestguess);

    guess = guesses(bestguess,:);
    
    for k = 1:numel(armstate_infos)
        guess(k) = armstate_infos(k).states(guess(k));
    end
    
    ddinfo = bundle(guesses,a, primscores);
else    
    guesses = mode(double(guesses));
    fprintf('loading data: ');
    tic
    [armstate_infos] = loadClipStatesEdges(clip, opts);   
      toc
    for k = 1:numel(armstate_infos)
        guess(k) = armstate_infos(k).states(guesses(k));
    end
    
    ddinfo = a;
    ddinfo.gap = min(dualvals)-maxprimval;
end



