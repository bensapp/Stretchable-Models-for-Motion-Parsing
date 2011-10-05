%% set paths
addpath utils boxutils
addpath inference models features
addpath discretization-info
addpath(genpath('cps'))
addpath(genpath('thirdparty'))

%% options: where you want all the temporary files saved:
opts.datadir = '/scratch/bensapp/tmp3/';

% shouldn't change these without re-learning a model
opts.imgdims = [333 370];
opts.larmlens = [17 32 47 66];

%% input: a list of filenames and array of bounding boxes (format [x1 y1 x2 y2]), as shown here:
files = dir3('example/*.jpg');
filenames = {files.filepath};
torsoboxes = load('example/torsoboxes.txt');

% show input video with labeled torsos
for i=1:length(filenames)
    cla, imagesc(imread(filenames{i})),
    axis image, hold on
    plotbox(torsoboxes(i,:),'w-');
    title('Input')
    drawnow
end
    
%% crop out person, resize to standard img dims


videoclip = normalizeImages(filenames,torsoboxes,opts);

% show crop centered video vlip
clf
for i=1:length(videoclip)
    cla, imagesc(imread(videoclip(i).imgfile)), 
    axis image, title('Scale and Translation Normalized')
    drawnow
end
    

%% run CPS model on each frame 
%% (this for-loop takes about 5 minutes / iter; trivially parallelized)
for i=1:length(videoclip)
   runCPS(opts,videoclip(i));
end

%% precompute a couple more sources of features 
%% flow (takes 15-20 seconds per frame-pair)
for i=1:length(videoclip)
    tic
   computeFlow(videoclip(i),imread(videoclip(min(end-1,i)).imgfile_orig),imread(videoclip(min(end,i+1)).imgfile_orig),opts)
   toc
end

%% hand dets (1.7 seconds / frame)
for i=1:length(videoclip)
   tic
   computeHandDetectors(videoclip(i),opts)
   toc
end

%% compute all model node and edge features from all feature sources (1 minute / frame)
[nodeInfo edgeInfo] = computeStatesAndFeatures(videoclip, opts)

%% inference 
w = loadvar('weights-all-models-all-features-best.mat','w');
submodels = getSubModelDefs;
opts.alpha = 1;
opts.do_initialize = false;
tic
mmarg_info = runEnsembleInference(nodeInfo, edgeInfo, w, submodels, opts);   
[max_marginals minmax] = computeSumMaxMarginals(mmarg_info);
toc

%%
guesses = [];
for i=1:length(max_marginals)
   guesses(i) = nodeInfo(i).states(argmax(max_marginals(i).max_marginal));
end
guesses = smoothSequence(nodeInfo(1).dims,guesses);

for i=1:length(videoclip)
    cla
    imagesc(imread(videoclip(i).imgfile)), axis image
    hold on
    plotMaxMarginals(nodeInfo, max_marginals, i, nodeInfo(1).imgdims);
    plotMAPdecode(nodeInfo, guesses, i, nodeInfo(1).imgdims,'w-','linewidth',5,'markersize',20);
    drawnow
end
