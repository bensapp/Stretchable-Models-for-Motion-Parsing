function runCPS(opts,example)
tstart = clock;

%% set up options


opts.imgfile = example.imgfile;
opts.prune_model_dir = './cps/prune_models/';
opts.predict_model_dir = './cps/predict_models/';
opts.nstates_max = 750;
[~,opts.filestem,~] =fileparts(example.imgfile);
opts.featuredir = sprintf('%s/cps-features/',opts.datadir);
opts.outputdir = opts.featuredir;
opts.force_precompute = false;

%% coarse to fine
tic
state_info = coarse_to_fine_pruning(opts);
toc
savefile = sprintf('%s/%s_pruned_states.mat',opts.featuredir,opts.filestem);
save(savefile,'state_info');

%show what states are left:
img = imread(opts.imgfile);

clf
imagesc(rgb2gray(img)), axis image, hold on, colormap gray
display_c2f_states(state_info,size(img));

%% complex features for final classification
t0 = clock;
clear feats
[feats.geometry,valid_binary_inds] = compute_geometry_features(state_info);
feats.color_dist = compute_pairwise_color_feats(opts,state_info,valid_binary_inds);
feats.hog = compute_hog_features(opts,state_info);
feats.face_clothes_color = compute_adaptive_color_features(opts,state_info);

%more expensive features involving normalized cuts
compute_pb_ncut(opts);
feats.regions = compute_region_features(opts,state_info);
feats.contours = compute_contour_features(opts,state_info,valid_binary_inds);
feats.embedding = compute_embedding_features(opts,state_info,valid_binary_inds);

delta_t = etime(clock,t0)
feats = reformat_feats(feats);
savefile = sprintf('%s/%s_feats.mat',opts.featuredir,opts.filestem);
save(savefile,'feats','valid_binary_inds');


% %% apply boosted classifiers to complex features and make final prediction
% [limb_guess,max_state_seq] = final_level_prediction(opts)
% display_limb_guess(opts,limb_guess);

tend = clock;

fprintf('CPS finished.  Took %s\n',sec2timestr(etime(tend,tstart)));