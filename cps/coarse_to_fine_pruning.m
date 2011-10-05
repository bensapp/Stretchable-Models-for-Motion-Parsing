function state_info = coarse_to_fine_pruning(opts)
%% get/load hog detection maps
detmapfile = fullfile(opts.outputdir,[opts.filestem,'_hog_detmaps.mat']);
if ~exist(detmapfile,'file') || opts.force_precompute
    compute_hog_part_detections(imread(opts.imgfile),opts);
end
detmaps = load2(detmapfile);


%% set up initial states
dims0 = [10 10 12];
ps_model = get_generic_ps_model(dims0);
state_info = setfield2(ps_model,'states',{(1:1200)'});


%% run through cascade
tic
n = length(dir3(fullfile(opts.prune_model_dir,'*.mat')));
state_infos = {};
state_infos{1} = state_info;
for i=1:n
    prune_model = load2(sprintf('%s/c2f_level%d_prune_model.mat',opts.prune_model_dir,i-1));
    feats = get_coarse_features(state_infos{i},detmaps);
    state_infos{i+1} = apply_pruning_model_to_examples(feats,state_infos{i},prune_model,opts.nstates_max);
end
0;

%just return the last stage of the cascade:
state_info = state_infos{end};
