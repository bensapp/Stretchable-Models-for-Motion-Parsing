function [limb_guess,max_state_seq] = final_level_prediction(opts)

models = arrayfun(@(x)(load2(x.filepath)),dir3([opts.predict_model_dir,'/*.mat']));

for i=1:length(models)
    models(i).modelfile = sprintf('%s/%s',opts.predict_model_dir,models(i).modelfile);
end

state_info = load2(fullfile(opts.outputdir,[opts.filestem,'_pruned_states.mat']));
feats = load2(fullfile(opts.outputdir,[opts.filestem,'_feats.mat']));
state_info = pairwise_boosting_scores_final_stage(state_info,feats,models);

for i=1:length(state_info)
     state_info(i).log_unary_clique = zeros(length(state_info(i).states),1);
     state_info(i).log_binary_clique = state_info(i).boosting_scores;
     state_info(i).valid_binary_inds = feats.valid_binary_inds(i).v;
end

max_state_seq = ps_model_max_inference_2clique_sparse_edges(state_info);
limb_guess = sequence2xyuv(state_info,max_state_seq);

return;
