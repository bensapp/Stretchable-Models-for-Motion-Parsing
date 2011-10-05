%% set up options
addpath utils/
addpath boxutils/
addpath part_detection_code/
addpath contour_code
addpath(genpath('./thirdparty/'))
clear opts
opts.imgfile = 'images/PASCAL/2007_000480.jpg';
%force re-computation of all intermediate files (HOG detmaps, ncut, etc):
opts.force_precompute = false;
%where to put all the saved data:
opts.outputdir = './output_pascal/';
[p,name,ext] = fileparts(opts.imgfile);
opts.filestem = name;
mkdir2(opts.outputdir);
% saved locations of model files
opts.prune_model_dir = './prune_models/';
opts.predict_model_dir = './predict_models/';
opts.nstates_max = 750;

%% coarse to fine
state_info = coarse_to_fine_pruning(opts);
savefile = sprintf('%s/%s_pruned_states.mat',opts.outputdir,opts.filestem);
save(savefile,'state_info');

%show what states are left:
img = imread(opts.imgfile);
imagesc(img), axis image, hold on
display_c2f_states(state_info,size(img))

%% complex features for final classification
clear feats;
[feats.geometry,valid_binary_inds] = compute_geometry_features(state_info);
feats.color_dist = compute_pairwise_color_feats(opts,state_info,valid_binary_inds);
feats.hog = compute_hog_features(opts,state_info);
feats.face_clothes_color = compute_adaptive_color_features(opts,state_info);

%more expensive features involving normalized cuts
compute_pb_ncut(opts);
feats.regions = compute_region_features(opts,state_info);
feats.contours = compute_contour_features(opts,state_info,valid_binary_inds);
feats.embedding = compute_embedding_features(opts,state_info,valid_binary_inds);

feats = reformat_feats(feats);
savefile = sprintf('%s/%s_feats.mat',opts.outputdir,opts.filestem);
save(savefile,'feats','valid_binary_inds');
%% apply boosted classifiers to complex features and make final prediction
[limb_guess,max_state_seq] = final_level_prediction(opts)
display_limb_guess(opts,limb_guess);

%save results
savefile = sprintf('%s/%s_final_prediction.mat',opts.outputdir,opts.filestem);
save(savefile,'limb_guess');