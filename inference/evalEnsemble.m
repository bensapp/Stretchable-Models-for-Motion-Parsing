function [info] = evalEnsemble(testset, submodels, w, alphas, opts)
      
errs = zeros(numel(alphas{1}), numel(alphas));
effs = zeros(numel(alphas{1}),numel(alphas));

n = 0;

% Training pass
for i = 1:numel(testset)
    
    clip = testset(i);
    fprintf('loading data: ');
    tic
    [armstate_infos edgeInfo] = loadClipStatesEdges(clip, opts);
    toc
    
    % ENSEMBLE INFERENCE
    mmarg_info = runEnsembleInference(armstate_infos, edgeInfo, w, submodels, opts);
    
    maxScore = sum([mmarg_info.maxScore]);
    meanScore = sum([mmarg_info.meanScore]);
    
    [max_marginals minmax] = computeSumMaxMarginals(mmarg_info);
    
    dispf('maxScore: %g, minmax: %g', maxScore, minmax);
    maxScore = min([maxScore minmax]);
    
    % tru state seq doesn't depend on which model is used
    tru_state_seq = mmarg_info(1).tru_state_seq;
    
    % compute agreement
    [pct(i) argmaxGuesses{i}] = argmaxagreement(mmarg_info);
    
    % compute error rate of posterior decoding
    mapGuesses = decodeMAP(armstate_infos, max_marginals);
    map_errs(i) = mean(mapGuesses ~= [tru_state_seq.state]);
    
    % compute error rate of voting decoding
    voteGuesses = mode(double(argmaxGuesses{i}));
    vote_errs(i) = mean(voteGuesses ~= [tru_state_seq.state]);
    
    % display some output
    dispf('%d: agreement %g', i, pct(i));
    dispf('%d: map error %g', i, map_errs(i));
    dispf('%d: voting error %g', i, vote_errs(i));
    
    % compute filter efficieny and error
    n = n + 1;
    
    for p = 1:numel(alphas)
        threshs{p} = alphas{p}.*maxScore + (1-alphas{p}).*meanScore;
        pidx = find([armstate_infos.partid]==p);
        
        % compute efficiency
        mm = vertcat(max_marginals(pidx).max_marginal);
        for j = 1:numel(threshs{p})
            effs(j,p) = effs(j,p) + sum(mm>=threshs{p}(j))/numel(mm);
        end
    end
    
    % compute error
    for p = 1:numel(alphas)
        m{p} = 0;
        ferrs{p} = zeros(numel(alphas{p}),1);
    end
    for j = 1:numel(max_marginals)
        p = armstate_infos(j).partid;
        
        % DONT COUNT CUMULATIVE ERRORS!!!
        if isempty(tru_state_seq(j).state), continue, end
        
        m{p} = m{p} + 1;
        trumm = max_marginals(j).max_marginal(tru_state_seq(j).state_ind);
        ferrs{p} = ferrs{p} + double(trumm<threshs{p})';
    end
    
    for p = 1:numel(alphas)
        errs(:,p) = errs(:,p) + ferrs{p}./m{p};
    end
    
end

errs = errs ./ n;
effs = effs ./ n;

info = bundle(errs,effs,pct,vote_errs,map_errs,argmaxGuesses);

end