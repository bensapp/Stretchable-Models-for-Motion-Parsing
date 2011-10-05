function [feats,valid_pairs] = compute_geometry_features(state_info)

% unary features
for i=1:length(state_info)
      feats(i).unary_features = unary_state_features(state_info(i));
      feats(i).name = state_info(i).name;
end

% binary features
for i=1:length(state_info)
    parent_ind = state_info(i).parent;
    if ~parent_ind, continue, end
    binary_data.state_dims = state_info(i).state_dims;

    binary_data.bin2angles = get_articulated_angles(binary_data.state_dims(3));
    binary_data.parent_state_dims = state_info(parent_ind).state_dims;
    binary_data.parent_length = state_info(parent_ind).dims(1);
    binary_data.child_length = state_info(i).dims(1);
    binary_data.mu = state_info(i).mu;
    binary_data.name = state_info(i).name;
    binary_data.bin2direction = angle2direction(binary_data.bin2angles);
    [feats(i).binary_features,valid_pairs(i).v] = binary_state_features(state_info(i).states,state_info(parent_ind).states,binary_data);
end
0;

function feats = unary_state_features(si)
states = si.states(:);
pts0 = ind2pts(si.state_dims,states);
pts = bsxfun(@times,double(pts0),1./si.state_dims([2 1 3])');
feats = pts';
0;

function [feats,ntf] = binary_state_features(states1,states2,data)
%% geometry
pts0 = ind2pts(data.state_dims,states1);
pts = bsxfun(@times,double(pts0),1./[data.state_dims([2 1])'; 1]);
parent_pts0 = ind2pts(data.parent_state_dims,states2);
parent_pts = bsxfun(@times,double(parent_pts0),1./[data.parent_state_dims([2 1])'; 1]);
parent_uv = data.bin2direction(:,parent_pts(3,:));
parent_uv_orth = orthogonal_unit_vectors_2d(parent_uv);
uv = data.bin2direction(:,pts(3,:));
joints = pts(1:2,:);
parent_joints = parent_pts(1:2,:);
parent_angles = atan2(parent_uv(2,:),parent_uv(1,:));
angles = atan2(uv(2,:),uv(1,:));

% only consider pairs which are reasonable: close to the mean connection
% spot
mu = data.mu./data.state_dims([2 1])';
assert(all(abs(mu)<1))

alluv = data.bin2direction;
alluv_orth = orthogonal_unit_vectors_2d(alluv);
for i=1:size(alluv,2)
    R =  [alluv_orth(:,i) alluv(:,i)];
    mu_dir(:,i) = R*mu;
end
mu_dirs = mu_dir(:,parent_pts(3,:));
parent_to_mu = parent_joints + mu_dirs;


r = 0.15;
too_far = mex_xy_points_too_far(joints(1,:),joints(2,:),parent_to_mu(1,:),parent_to_mu(2,:),r);
[inds1,inds2] = find(~too_far);
inds1 = int32(inds1(:)); inds2 = int32(inds2(:));
pairwise_inds = double(sub2ind2([length(states1) length(states2)],inds1,inds2));


mex_feats = mex_limb_pair_geometry_sparse_inds(inds1-1,inds2-1,joints,parent_to_mu,uv,parent_uv,parent_uv_orth,angles, parent_angles)';
ntf = ~too_far;

feats = zeros(length(states1)*length(states2),size(mex_feats,2));
feats(pairwise_inds,:) = mex_feats;
feats(:,end+1) = too_far(:);
