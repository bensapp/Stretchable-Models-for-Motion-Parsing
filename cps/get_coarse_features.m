function ps_model = get_coarse_features(ps_model,detmaps)
load part_detection_code/HOG_detmap_histograms.mat H

% unary features
for i=1:length(ps_model)
    h = H(strcmp({H.name},ps_model(i).name));
    unary_data.maxval = h.maxval;
    unary_data.minval = h.minval;
    
    d = (detmaps(strcmp(ps_model(i).name,{detmaps.name})).detmap);
    d = resize_detmap(d,ps_model(i).state_dims);
    unary_data.detmap = d;
    ps_model(i).unary_features = unary_state_features(ps_model(i).states,unary_data);
end

% binary features
for i=1:length(ps_model)
    parent_ind = ps_model(i).parent;
    if ~parent_ind, continue, end
    binary_data.state_dims = ps_model(i).state_dims;

    binary_data.bin2angles = get_articulated_angles(binary_data.state_dims(3));
    binary_data.parent_state_dims = ps_model(parent_ind).state_dims;
    binary_data.parent_length = ps_model(parent_ind).dims(1);
    binary_data.child_length = ps_model(i).dims(1);
    binary_data.mu = ps_model(i).mu;
    binary_data.name = ps_model(i).name;
    binary_data.bin2direction = angle2direction(binary_data.bin2angles);
    ps_model(i).binary_features = binary_state_features(ps_model(i).states,ps_model(parent_ind).states,binary_data);
end

function feats = unary_state_features(states,data)
states = states(:);
feats = logical(binarize_data_matrix(data.detmap(states),20,data.minval,data.maxval));
assert(~any(sum(feats,2)==0))
ngrid = 10;
pts0 = ind2pts(size(data.detmap),states);
pts = bsxfun(@times,double(pts0),1./size2(data.detmap,[2 1 3])');
subinds = floor(max(pts(1:2,:)*ngrid-1e-8,0))+1;
inds = sub2ind([ngrid ngrid],subinds(2,:),subinds(1,:));
location_prior = sparse(1:length(inds),inds,true,length(inds),ngrid*ngrid);
angle_id_feats = sparse(1:size(feats,1),double(pts0(3,:)),true,size(feats,1),size(data.detmap,3));
feats = [feats angle_id_feats location_prior];
0;

function feats = binary_state_features(states1,states2,data)
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


r = 0.20;

%%
if 0 && data.state_dims(3) > 12
    cla; myquiver(parent_joints,parent_to_mu-parent_joints), axis ij, axis([0 1 0 1])
    hold on; myplot(joints)
    title(data.name)
    
    myplot(parent_to_mu(:,8),'ko')
    myplot(joints(:,find(d(:,8)<(r*r))),'bo')
    myplot(joints(:,find(~too_far(:,8))),'ro','markersize',12)
    0;
end
%%
if 0
    tic
    Xreference = joints;
    Xquery = parent_to_mu;
    d=XY2distances(Xreference',Xquery');
    [inds1,inds2] = find(d<r*r);
    inds1 = int32(inds1); inds2 = int32(inds2);
    pairwise_inds2 = double(sub2ind2([length(states1) length(states2)],inds1,inds2));
    toc
else
%     tic
    too_far = mex_xy_points_too_far(joints(1,:),joints(2,:),parent_to_mu(1,:),parent_to_mu(2,:),r);
    [inds1,inds2] = find(~too_far);
    inds1 = int32(inds1); inds2 = int32(inds2);
    pairwise_inds = double(sub2ind2([length(states1) length(states2)],inds1,inds2));
%     toc
end

mex_feats = mex_limb_pair_geometry_sparse_inds(inds1-1,inds2-1,joints,parent_to_mu,uv,parent_uv,parent_uv_orth,angles, parent_angles)';

angle_grid = 30;
angle_ids = floor(wrapTo2Pi(mex_feats(:,5))/(2*pi)*angle_grid)+1;
angle_feats = sparse(pairwise_inds,angle_ids,true,length(states1)*length(states2),angle_grid+1);

distgrid = min(min(data.state_dims([2 1])),30);
xy = (mex_feats(:,1:2)'+r)/(2*r);
xyf = floor(xy*distgrid)+1;
xyf(xyf>distgrid) = distgrid;
xyf(xyf<1) = 1;
dist_inds = sub2ind2(distgrid([1 1]),xyf(2,:),xyf(1,:));
dist_feats = sparse(pairwise_inds,dist_inds,true,length(states1)*length(states2),distgrid^2);

not_too_far = sparse(pairwise_inds,1,true,length(states1)*length(states2),1);
feats = [dist_feats angle_feats not_too_far];