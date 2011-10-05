function state_info = pairwise_boosting_scores_final_stage(state_info,feats,models)
valid_binary_inds = feats.valid_binary_inds;
feats = feats.feats;
for i=1:length(state_info)
    parent_i = state_info(i).parent;
    if parent_i == 0, continue, end
    modelind = find(strcmp({models.name1},state_info(i).name) & strcmp({models.name2},state_info(parent_i).name));
    %concat features
    X = featspair2mat(feats(i),feats(parent_i),fields(feats));
    
    v = valid_binary_inds(i).v;
    boosting_scores = zeros(size(X,1),1);
    s = eval_boosting_model(X(v,:),models(modelind));
    
    boosting_scores(v(:)) = s;
    
    boosting_scores(~v(:)) = min(s);
    state_info(i).boosting_scores = reshape(boosting_scores,size(v));
    
end


function scores2 = eval_boosting_model(X,model)

scores = mex_opencv_boosting('test',X,[],model.modelfile,model.best_round);
scores2 = sum(scores,2);


