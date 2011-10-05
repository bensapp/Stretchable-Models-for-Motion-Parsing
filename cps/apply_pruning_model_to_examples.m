function state_info = apply_pruning_model_to_examples(feats,state_info,prune_model,nstates_max)

for j=1:length(feats)
    assert(isequal(prune_model(j).name,feats(j).name))
    prune_model(j).unary_features = feats(j).unary_features;
    prune_model(j).binary_features = feats(j).binary_features;
    prune_model(j).states = feats(j).states;
end

prune_model = compute_clique_scores(prune_model);
[max_state_seq, max_marginals] = ps_model_max_inference_2clique_sparse_edges(prune_model);

state_set = threshold_and_map_states(prune_model,max_marginals,nstates_max);

state_info = rmfield2(feats,{'unary_features','binary_features'});
for j=1:length(state_info)
    state_info(j).states = state_set{j};
    state_info(j).state_dims = prune_model(j).next_state_dims;
end
state_info = set_state_dims(state_info,cat(1,prune_model.next_state_dims),cat(1,prune_model.state_dims));


function state_set = threshold_and_map_states(prune_model,max_marginals,nstates_max)
%% prune
state_set0 = {};
for i=1:length(prune_model)
    assert(isequal(max_marginals(i).name,prune_model(i).name));
    
    mmi = max_marginals(i).max_marginal;
    mmi = mmi(mmi>-1e300);
    mean_val = mean(mmi);
    max_val = max(mmi);
    
    alpha_i = prune_model(i).test_alpha;
    threshold = alpha_i*max_val + (1-alpha_i)*mean_val;
    
    states = prune_model(i).states;
    state_set0{i} = states(max_marginals(i).max_marginal>threshold);
end

%% refine
dims = cat(1,prune_model.state_dims);
next_dims = cat(1,prune_model.next_state_dims);
for i=1:length(prune_model)
    %either only change angle or xy
    
    %change angle:
    if dims(i,3)~=next_dims(i,3)
        assert(isequal(dims(i,1:2),next_dims(i,1:2)))
        %assume we double the angles for now...
        assert(next_dims(i,3)/dims(i,3)==2)
        pts = ind2pts(dims(i,:),state_set0{i});
        [pts1,pts2] = deal(pts);
        pts1(3,:) = pts1(3,:)*2;
        pts2(3,:) = pts2(3,:)*2-1;
        new_pts = [pts1 pts2];
        new_inds = sub2ind(next_dims(i,:),new_pts(2,:),new_pts(1,:),new_pts(3,:));
        state_set{i} = new_inds(:);
        0;
    else %change xy
        inds = map_states_up(state_set0{i},dims(i,:),next_dims(i,:));
        %subsample to nstates_max if necessary, uniformly at random:
        inds = inds(unique(round(linspace(1,length(inds),nstates_max))));
        state_set{i} = inds;
        0;
    end
    0;
end



function inds = map_states_up(states,dims,dims0)
cube = false(dims);
cube(states) = true;
% cube0=imresize_nearest(cube,dims0);
cube0=resize_detmap(cube,dims0,'nearest');
inds = int32(find(cube0(:)));
0;


function ps_model = set_state_dims(ps_model,state_dims,dims0)
if size(state_dims,1) == 1, state_dims = repmat(state_dims,length(ps_model),1); end
if size(dims0,1) == 1, dims0 = repmat(dims0,length(ps_model),1); end
for i=1:length(ps_model)
    ps_model(i).state_dims = state_dims(i,:);
    ps_model(i).mu = ps_model(i).mu./dims0(i,[2 1])'.*state_dims(i,[2 1])';
    ps_model(i).dims = ps_model(i).dims ./ dims0(i,1:2) .* state_dims(i,1:2);
end