function state_info = coarse_to_fine_pruning_old(opts)
%% get/load hog detection maps




%% set up initial states
dims0 = [10 10 12];
ps_model = get_generic_ps_model(dims0);
state_info = setfield2(ps_model,'states',{(1:1200)'});


%% run through cascade
0;
tic
n = length(dir3(fullfile(opts.prune_model_dir,'*.mat')));
for i=1:n
    
    %load hog
    sfuns = sparse_ps_funs;
    example.fileinfo.filepath = opts.imgfile;
    example.scale = 1;
    state_info = sfuns.add_data(state_info,example);
    
%     tic
    prune_model = load2(sprintf('%s/c2f_level%d_prune_model.mat',opts.prune_model_dir,i-1));
    feats = get_coarse_features_old(state_info);
    state_info = apply_pruning_model_to_examples(feats,state_info,prune_model,opts.nstates_max);
%     toc
end
toc
