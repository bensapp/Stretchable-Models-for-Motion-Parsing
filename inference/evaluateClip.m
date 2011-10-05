function [info,armstate_infos] = evaluateClip(clip, w, opts,featuresel)

submodels = getSubModelDefs;

%%
fprintf('loading data: ');
tic
[armstate_infos edgeInfo] = loadClipStatesEdges(clip, opts);
toc

%{ 
    %%
submodels = getSubModelDefs;

for j = 1:numel(w)
    pairs = [1 3;
        2 4;
        3 5;
        4 6];
    for k = 1:rows(pairs)
        p = pairs(k,1); c = pairs(k,2);
        if ~isempty(w(j).binary_w{p,c})
            %size(w(j).binary_w{p,c})
            %w(j).binary_w{p,c}(11:32) = 0;
            w(j).binary_w{p,c}(1:end) = 0;
        end
        if ~isempty(w(j).binary_w{c,p})
            %size(w(j).binary_w{c,p})
            w(j).binary_w{c,p}(1:end) = 0;
        end
    end
    
    %
    
    pairs = [3 4];
    for k = 1:rows(pairs)
        p = pairs(k,1); c = pairs(k,2);
        if ~isempty(w(j).binary_w{p,c})
            %w(j).binary_w{p,c}(1:10) = 0;
        end
        if ~isempty(w(j).binary_w{c,p})
            %w(j).binary_w{c,p}(1:10) = 0;
        end
    end
    
    for p = [3 4]
        %w(j).unary_w{p} = zeros(size(w(j).unary_w{p}));
    end
    
    pairs = [1 3; 2 4];
    for k = 1:rows(pairs)
        p = pairs(k,1); c = pairs(k,2);
        if ~isempty(w(j).binary_w{p,c})
            %w(j).binary_w{p,c}(43:end) = 0;
        end
        if ~isempty(w(j).binary_w{c,p})
            %w(j).binary_w{c,p}(43:end) = 0;
        end
    end
end
%%
for j = numel(w)
    %     for k = 1:numel(w(j).binary_w)
    %         if ~isempty(w(j).binary_w{k})
    %             w(j).binary_w{k} = zeros(size(w(j).binary_w{k}));
    %         end
    %     end
    for p = [3 4]
        w(j).unary_w{p}(1:end)= 0;
    end
    
end
%}
%%


armstate_infos = fixFeatureInds(armstate_infos);

if exist('featuresel','var') && ~isempty(featuresel)
    [armstate_infos edgeInfo] = selectFeatures(armstate_infos,edgeInfo,featuresel);
end

% ENSEMBLE INFERENCE
mmarg_info = runEnsembleInference(armstate_infos, edgeInfo, w, submodels, opts);   
[max_marginals minmax] = computeSumMaxMarginals(mmarg_info);


%%

mapGuess = decodeMAP(armstate_infos, max_marginals);
[pct_agreement argmaxGuesses] = argmaxagreement(mmarg_info);

for p = 1:6
    m = strmatch(getArmPartName(p), {submodels.root});
    pidx = find([armstate_infos.partid]==p);
        
    guesslocal = [mmarg_info(m).max_state_seq.state];
    guesshack(pidx) = guesslocal(pidx);
end

voteGuess = mode(double(argmaxGuesses));
disagree = sum(bsxfun(@eq, argmaxGuesses, voteGuess));
badidx = find(disagree == 1);
numbad = numel(badidx);
voteGuess(badidx) = mapGuess(badidx);

[vote_err vote_ang] = evalGuesses(armstate_infos, voteGuess);
[map_err map_ang] = evalGuesses(armstate_infos, mapGuess);
[hack_err hack_ang] = evalGuesses(armstate_infos, guesshack);
for j = 1:rows(argmaxGuesses)
   submodel_err{j} = evalGuesses(armstate_infos, argmaxGuesses); 
end

%plotMAPdecode(armstate_infos, guesshack, 22);

%% get ECCV predictions

eccv_guess= getECCVPredictions(armstate_infos);

[eccv_err eccv_ang] = evalGuesses(armstate_infos, eccv_guess);

%% get ferrari predictions

ferrari_guess = getFerrariPredictions(armstate_infos);
[ferrari_err ferrari_ang] = evalGuesses(armstate_infos, ferrari_guess);
%
info = bundle(pct_agreement, mapGuess,guesshack,eccv_guess,...
    ferrari_guess, argmaxGuesses, max_marginals, ...
    vote_err,vote_ang, voteGuess,badidx,numbad, ...
    map_err,hack_err,eccv_err,submodel_err, ferrari_err,...
    map_ang, hack_ang, eccv_ang,ferrari_ang);
 

%{
if 0
   %%
   %plotMAPdecode(armstate_infos, [mmarg_info(6).max_state_seq.state], 22);
   %for i = 1:17
       i = 1;
       tic;
       [armstate_infos] = loadClipStatesEdges(clips(testidx(i)), opts); toc
       [guess_dd] = getDDPredictions(clips(testidx(i)), w, opts, false);
       
       %dd{i} = guess_dd;
       
       %    clip = clips(testidx(i));
%    filename = armtracking_root('dd_guess', ...
%        clip.moviename, ...
%        sprintf('%08d.mat', clip.examples(1).currframe));
%    
   
   
   %end

%%
clrs = lines(3);

%for t = 1:5:15 
t = 1;i = 1;
framenum = 1;
 figure(1);
 clf;
 
 img = imread(armtracking_root('jpg-torso-cropped', clips(testidx(i)).moviename, ...
     sprintf('%08d.jpg', clips(testidx(i)).examples(t).currframe)));
 imsc(img); axis image;
 imgdims = armstate_infos(1).imgdims;
 pts = [];
 pts1 = plotMAPdecode(armstate_infos, eccv_guess, t, imgdims, '-dm','MarkerSize',10,'LineWidth',5,'MarkerFaceColor','m');
 pts2 = plotMAPdecode(armstate_infos, mapGuess, t, imgdims, '-sc','MarkerSize',10,'LineWidth',5,'MarkerFaceColor','g');
 pts3 = plotMAPdecode(armstate_infos, guesshack, t,  imgdims, '-vb','MarkerSize',10,'LineWidth',5,'MarkerFaceColor','c');
 pts4 = plotMAPdecode(armstate_infos, convertGuessToState(armstate_infos, guess_dd), t, imgdims, '-oy','MarkerSize',10,'LineWidth',5,'MarkerFaceColor','c');
 
 pts = [pts1 pts2 pts3 pts4];
 %ylim([0.5, max(pts(2,:))+20]);
 %xlim([min(pts(1,:))-40, max(pts(1,:))+20]);
 
 %filename = armtracking_root('figs', sprintf('example-%02d.png',framenum));
    %print('-dpng','-r500',filename);
framenum = framenum + 1;
%end

%%
clrs = lines(6);
 t = 10;
 figure(1);
 clf;
 
 img = imread(armtracking_root('jpg-torso-cropped', clips(testidx(i)).moviename, ...
     sprintf('%08d.jpg', clips(testidx(i)).examples(t).currframe)));
 imsc(img); axis image;
 
    for p = 1:6
         hold on;
         plotMAPdecode(armstate_infos, results(i).argmaxGuesses(p,:), t, 'LineWidth',12,'Color', clrs(p,:));  %'MarkerSize',20,'LineWidth',5);
    
         xlim([22 300]);
         ylim([0 220]);


%         print('-dpng','-r600',
%   
    end
    filename = armtracking_root('figs', sprintf('submodels.png'));
    print('-dpng','-r500',filename);
    
    figure(2);
    clf;
    imsc(img); axis image;
    plotMAPdecode(armstate_infos, results(i).eccv_guess, t,  '-dm','MarkerSize',20,'LineWidth',10,'MarkerFaceColor','m');
    plotMAPdecode(armstate_infos, guess_dd, t,  '-oy','MarkerSize',20,'LineWidth',10,'MarkerFaceColor','y');
     xlim([22 300]);
         ylim([0 220]);

    %xlim([21 370]);
    %ylim([0 235]);
    filename = armtracking_root('figs', sprintf('dd.png'));
    print('-dpng','-r500',filename);
 
    
%    figure(3);
 %   imsc(img); axis image;
  
 
%    filename = armtracking_root('figs', sprintf('submodel-%s.png', getArmPartName(p)));
%    print('-dpng','-r300',filename);
%    
%%
    
     plotMAPdecode(armstate_infos, voteGuess, 8, '-oc','MarkerSize',20,'LineWidth',5);
     %xlim([21 370]);
     %ylim([0 235]);

   
end
%}
%
