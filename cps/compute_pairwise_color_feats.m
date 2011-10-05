function feats = compute_pairwise_color_feats(opts,state_info,valid_binary_inds)

%unary features: none
for i=1:length(state_info)
    feats(i).name = state_info(i).name;
end

img = imread(opts.imgfile);
binary_data.img8 = rgb2ind(img,8,'nodither');
% binary features
for i=1:length(state_info)
    parent_ind = state_info(i).parent;
    if ~parent_ind, continue, end
    binary_data.state_dims = state_info(i).state_dims;
    binary_data.img8 = imresize(binary_data.img8,binary_data.state_dims(1:2),'nearest');
    binary_data.bin2angles = get_articulated_angles(binary_data.state_dims(3));
    binary_data.parent_state_dims = state_info(parent_ind).state_dims;
    binary_data.parent_length = state_info(parent_ind).dims(1);
    binary_data.child_length = state_info(i).dims(1);
    binary_data.mu = state_info(i).mu;
    binary_data.name = state_info(i).name;
    [binary_data.inds1,binary_data.inds2] = find(valid_binary_inds(i).v);
    binary_data.bin2direction = angle2direction(binary_data.bin2angles);
    feats(i).binary_features = binary_state_features(state_info(i).states,state_info(parent_ind).states,binary_data);
end


0;

function feats = binary_state_features(states1,states2,data)
kid_dims = [data.child_length data.child_length/4];
parent_dims = [data.parent_length data.parent_length/4];
pts0 = double(ind2pts(data.state_dims,states1));
parent_pts0 = double(ind2pts(data.parent_state_dims,states2));
uv = data.bin2direction(:,pts0(3,:));
parent_uv = data.bin2direction(:,parent_pts0(3,:));
uv_orth = orthogonal_unit_vectors_2d(uv);
parent_uv_orth = orthogonal_unit_vectors_2d(parent_uv);

patches1 = get_img_patches(pts0,uv,uv_orth,kid_dims.*[0.8 1],data.img8);
patches2 = get_img_patches(parent_pts0,parent_uv,parent_uv_orth,parent_dims.*[0.8 1],data.img8);

h1 = sum_to_1(histc(patches1,0:7),1);
h2 = sum_to_1(histc(patches2,0:7),1);
chi2_feats = mex_indij2distances_chisquared([h1 h2],data.inds1,size(h1,2)+data.inds2,false);
pairwise_inds = double(sub2ind2([length(states1) length(states2)],data.inds1,data.inds2));
feats = zeros(length(states1)*length(states2),size(chi2_feats,2));
feats(pairwise_inds,:) = chi2_feats;
0;


function [patches,res] = get_img_patches(pts,uv,uv_orth,dims,img8)
tl = pts(1:2,:)-uv_orth*dims(2)/2;
tr = pts(1:2,:)+uv_orth*dims(2)/2;
bl = tl+uv*dims(1);
br = tr+uv*dims(1);
for i=1:size(tl,2)
    boxr = [tl(:,i) tr(:,i) br(:,i) bl(:,i)];
    res(i).patch = extractRotatedBox(boxr,img8,true);
    
    display = 0;
    if display
        figure(1)
        imsc(img8)
        hold on
        plotboxrot(boxr,'w-','linewidth',5)
        
        figure(2)
        imsc(res(i).patch)
        drawnow
        0;
    end
end
v = arrayfun(@(x)(x.patch(:)),res,'uniformoutput',0);
patches = [v{:}];