function [best_w trainlog opts whist nupdates] = learnArmTrackingEnsemble(trainset, devset, submodels, w, featuresel, opts, varargin)

% obtain training values
defaults.num_iterations = 3;
defaults.learn_rate = 1;
defaults.verbosity = 2;
defaults.alpha = 0;
defaults.max_err = 0.05; % 5% error
defaults.lambda = .1;
defaults.do_eval = false;
defaults.vis = false;
defaults.tie_weights = false;
defaults.savefile = 'tmp.mat';

opts = mergestructs(opts,propval(varargin, defaults));

opts

% whist keeps history of all weights through training
wavg = w;
whist = w;


num_avg = 0;
nupdates = 0;

dispf('%d TRAINING EXAMPLES', numel(trainset));

% stem = ['trainlog_w-lam' num2str(opts.lambda) '-a' num2str(opts.alpha)];
% filectr = 0;
% filename = stem;
% while exist([filename '.mat'])
%     filename = sprintf('%s%02d', stem, filectr);
%     
%     filectr = filectr + 1;
% end
filename = opts.savefile;

dispf('saving to: %s', filename);
        
for t = 1:opts.num_iterations
    fprintf('----------------\n iter = %d / %d \n-------------------\n',t,opts.num_iterations)

    trainset = shuffle(trainset);
   
    t00 = clock;
    for i = 1:numel(trainset)

        t0 = clock;

        try 
            
            % LOAD DATA
            clip = trainset(i);
            
            if length(trainset)>1 || t==1
                fprintf('loading data: ');
                tic
                [armstate_infos edgeInfo] = loadClipStatesEdges(clip, opts);
                
                toc
            else
                fprintf('keeping clip data in memory\n');
            end

        catch
            warning('unable to load clip %d',i);
            clip
            
            continue;
        end
        
        %FEATURE SELECTION
        armstate_infos = fixFeatureInds(armstate_infos);
        [armstate_infos edgeInfo] = selectFeatures(armstate_infos,edgeInfo,featuresel);

        % ENSEMBLE INFERENCE
        mmarg_info = runEnsembleInference(armstate_infos, edgeInfo, w, submodels, opts);
   
        truScore = sum([mmarg_info.truScore]);
        thresh = sum([mmarg_info.thresh]);
        
        % compute agreement
        pct = argmaxagreement(mmarg_info);
        dispf('%d: agreement %g', i, pct);
        
        % ----- visualization
        if opts.vis
            figure(1);
            max_marginals = computeSumMaxMarginals(mmarg_info);
            plotMarginalsHeatmap(armstate_infos, mmarg_info(1).max_marginals, 1, [5 6], ...
                'topK', 1/4, 'blurwidth', 2, 'mix_coeff',3, 'falloff', 4);
        end
        % -----
        
        L = length(armstate_infos);
        if (truScore <= thresh + L)
            
            nupdates = nupdates + 1;
            if opts.verbosity > 1
                fprintf('violation: %g < (%g + %g) - updating...', ...
                    truScore/L, thresh/L, 1);
            end
            
            if opts.tie_weights
                wbatch = w;
                
                for k = 1:numel(wbatch.unary_w)
                    wbatch.unary_w{k} = zeros(size(wbatch.unary_w{k}));
                end
                for k = 1:numel(wbatch.binary_w)
                    wbatch.binary_w{k} = zeros(size(wbatch.binary_w{k}));
                end

                
            end
                
            if opts.verbosity > 1, fprintf('Updating...\n'); end
            for j = 1:numel(submodels)
                if opts.verbosity > 1, fprintf('Building model %d: ', j);tic; end
                treenodes = makeArmTrackingTreeModel(armstate_infos, submodels(j));
                treenodes = insertPrecomputedFeatures(treenodes, edgeInfo);
                if opts.verbosity > 1, toc; end
    
                if opts.tie_weights
                    if opts.verbosity > 1 
                        fprintf('gathering SHARED WEIGHTS batch update\n');
                    end
                    
                    % update unary weights
                    wbatch.unary_w = updateMeanMaxUnaryWeights(treenodes, ...
                        mmarg_info(j).max_counts, ...
                        mmarg_info(j).max_state_seq, ...
                        wbatch.unary_w, opts.alpha, opts.learn_rate, opts.lambda);
                    
                    % update pairwise terms
                    wbatch.binary_w = updateMeanMaxPairwiseWeights(treenodes, ...
                        mmarg_info(j).max_counts, ...
                        mmarg_info(j).max_state_seq, ...
                        wbatch.binary_w, opts.alpha, opts.learn_rate, opts.lambda);
                    
                else
                    % update unary weights
                    w(j).unary_w = updateMeanMaxUnaryWeights(treenodes, ...
                        mmarg_info(j).max_counts, ...
                        mmarg_info(j).max_state_seq, ...
                        w(j).unary_w, opts.alpha, opts.learn_rate, opts.lambda);
                    
                    % update pairwise terms
                    w(j).binary_w = updateMeanMaxPairwiseWeights(treenodes, ...
                        mmarg_info(j).max_counts, ...
                        mmarg_info(j).max_state_seq, ...
                        w(j).binary_w, opts.alpha, opts.learn_rate, opts.lambda);
                    
                    wavg(j) = addWeights(wavg(j), w(j));
                    
                    for k = 1:numel(whist(j).unary_w), whist(j).unary_w{k} = [whist(j).unary_w{k} w(j).unary_w{k}]; end
                    for k = 1:numel(whist(j).binary_w), whist(j).binary_w{k} = [whist(j).binary_w{k} w(j).binary_w{k}]; end
                end
            end
            
            if opts.tie_weights
                if opts.verbosity > 1, fprintf('UPDATING TIED WEIGHT MINIBATCH\n'); end
                
                for k = 1:numel(wbatch.unary_w)
                    w.unary_w{k} = w.unary_w{k} + wbatch.unary_w{k};
                end
                for k = 1:numel(wbatch.binary_w)
                    w.binary_w{k} = w.binary_w{k} + wbatch.binary_w{k};
                end

                wavg = addWeights(wavg, w);
                for k = 1:numel(whist.unary_w), whist.unary_w{k} = [whist.unary_w{k} w.unary_w{k}]; end
                for k = 1:numel(whist.binary_w), whist.binary_w{k} = [whist.binary_w{k} w.binary_w{k}]; end                
            end
            if opts.verbosity > 1, fprintf('done.\n'); end
            
        end % end update
        num_avg = num_avg + 1;

        % ---- visualization
        if opts.vis
            sfigure(4);  mm = 1;   ww = 1;
            cla, plot(bsxfun(@times,cumsum(whist(mm).unary_w{ww},2),1./(1:size(whist(mm).unary_w{ww},2)))')
            drawnow
        end
        % ----
      
        save(filename,'w','wavg','num_avg','whist','opts');
        
        elapsed = etime(clock, t0);
        dispf('------- TIME FOR EXAMPLE: %s -------', sec2timestr(elapsed));
        total_elapsed = etime(clock, t00);
        rate = total_elapsed / i;
        esttime = rate*numel(trainset);
        dispf('------- EST TIME PER TRAINING ITERATION %s -------', sec2timestr(esttime));
    end
    if opts.verbosity > 0, fprintf('iter %d: %d total training updates.\n', t,nupdates); end
    
    fprintf('----------------\n DEVSET iter = %d / %d \n-------------------\n',t,opts.num_iterations)

    if opts.do_eval 
        for p = 1:6
            alphas{p} = [opts.alpha];
        end
        
        info = evalEnsemble(devset, submodels, w, alphas, opts);
        
        fprintf('-----------\n');
        dispf('mean MAP decoding error: %g', mean(info.map_errs));
        dispf('mean (across part) filter error (alpha=%g): %g', opts.alpha, mean(info.errs));
        dispf('mean (across part) filter eff   (alpha=%g): %g', opts.alpha, mean(info.effs));
    else
        info = opts; % dummy 
    end
    
    % For now, every round is best round...
    best_w = wavg;
    for j = 1:numel(best_w)
        for k = 1:numel(best_w(j).unary_w), best_w(j).unary_w{k} = best_w(j).unary_w{k} ./ num_avg; end
        for k = 1:numel(best_w(j).binary_w), best_w(j).binary_w{k} = best_w(j).binary_w{k} ./ num_avg; end
    end
    
    trainlog(t) = info;
            
end

