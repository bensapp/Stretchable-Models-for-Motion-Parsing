function result = collect_feats_example(example,state_info,feats,fnames)
valid_binary_inds = feats.valid_binary_inds;
feats = feats.feats;
nb_neg = 2500;
for i=1:length(state_info)
    parent_i = state_info(i).parent;
    if parent_i == 0, continue, end
    
    
   [posinds,neginds] = get_pos_neg_examples(state_info(i),state_info(parent_i),example,valid_binary_inds(i).v,nb_neg);
   
   
   %concat features
   X = featspair2mat(feats(i),feats(parent_i),fnames);
   result(i).Xpos = X(posinds,:);
   result(i).Xneg = X(neginds,:);
   result(i).name = [state_info(i).name,'-',state_info(parent_i).name];

end





function [pos_inds,neg_inds] = get_pos_neg_examples(si1,si2,example,vbi,nbMax)
%distance from groundtruth in normalized (0..1x0..1x0..1) coordinates
pos_dist_cutoff1 = 0.15;
neg_dist_cutoff1 = 0.25;
pos_dist_cutoff2 = 0.15;
neg_dist_cutoff2 = 0.25;

% if isequal(si1.name,'llarm') || isequal(si1.name,'rlarm')
%     pos_dist_cutoff1 = 0.25;
%     neg_dist_cutoff1 = 0.35;
% end

% get groundtruth
gt2ind = @(name)(strcmp({example.parts.name},name));
gt1 = example.parts(gt2ind(si1.name));
gt2 = example.parts(gt2ind(si2.name));
gt1_endpts = gt1.pts ./ example.ex_size([1 1],[2 1])' .* si1.state_dims([1 1],[2 1])';
gt2_endpts = gt2.pts ./ example.ex_size([1 1],[2 1])' .* si2.state_dims([1 1],[2 1])';

% compute normalized distances
part_length1 = norm(diff(gt1_endpts,1,2));
part_length2 = norm(diff(gt2_endpts,1,2));
pts1 = states2endpts(si1.states,si1.state_dims,part_length1);
pts2 = states2endpts(si2.states,si2.state_dims,part_length2);

dists1 = max_endpt_dist(pts1,gt1_endpts);
dists2 = max_endpt_dist(pts2,gt2_endpts);

pos_inds1 = (dists1 <= pos_dist_cutoff1);
neg_inds1 = (dists1 > neg_dist_cutoff1);
pos_inds2 = (dists2 <= pos_dist_cutoff2);
neg_inds2 = (dists2 > neg_dist_cutoff2);

%% display
display = 0;
if display
    img = imread(example.fileinfo.filepath);
    clf,imsc(imresize(img,[80 80])), axis image
    hold on
    
    % myline(pts1,'color','b')
    % myline(pts2,'color','g')
    
    myline(pts2(:,1:2:end,neg_inds2),'color','b')
    myline(pts2(:,:,pos_inds2),'color','g')
    
    myline(pts1(:,1:2:end,neg_inds1),'color','b')
    myline(pts1(:,:,pos_inds1),'color','g')
    
    myplot(gt2_endpts,'w-','linewidth',1)
    myplot(gt1_endpts,'w-','linewidth',1)
    drawcircle(gt1_endpts(:,1),pos_dist_cutoff1*part_length1,'w-')
    drawcircle(gt1_endpts(:,2),pos_dist_cutoff1*part_length1,'w-')
    drawcircle(gt2_endpts(:,1),pos_dist_cutoff2*part_length2,'w-')
    drawcircle(gt2_endpts(:,2),pos_dist_cutoff2*part_length2,'w-')
    
    drawcircle(gt1_endpts(:,1),neg_dist_cutoff1*part_length1,'w--')
    drawcircle(gt1_endpts(:,2),neg_dist_cutoff1*part_length1,'w--')
    drawcircle(gt2_endpts(:,1),neg_dist_cutoff2*part_length2,'w--')
    drawcircle(gt2_endpts(:,2),neg_dist_cutoff2*part_length2,'w--')
    
    fprintf('# pos inds 1: %d\n',sum(pos_inds1))
    fprintf('# pos inds 2: %d\n',sum(pos_inds2))
    0;
end

%% get pairwise indices
n1 = length(si1.states);
n2 = length(si2.states);

pos_mask = get_pairwise_inds(pos_inds1,pos_inds2,vbi);
pos_inds = find(pos_mask(:));

% 3 types of negative examples: both parts "incorrect", or either part
% "incorrect"
neg_mask = false(size(vbi));
% neg_mask = neg_mask | get_pairwise_inds(neg_inds1,pos_inds2,vbi);
% neg_mask = neg_mask | get_pairwise_inds(pos_inds1,neg_inds2,vbi);
neg_mask = neg_mask | get_pairwise_inds(neg_inds1,neg_inds2,vbi);
neg_inds = find(neg_mask(:));
if length(neg_inds) > nbMax
   neg_inds = shuffle(neg_inds);
   neg_inds = sort(neg_inds(1:nbMax));
end

%% display 2

if display
    img = imread(example.fileinfo.filepath);
    clf,imagesc(imresize(img,[80 80])), axis image
    hold on
    
    [i1,i2] = ind2sub(size(vbi),neg_inds);
    myline(pts1(:,:,i1),'color','b')
    myline(pts2(:,:,i2),'color','b')
    
    [i1,i2] = find(pos_mask);
    myline(pts1(:,:,i1),'color','g')
    myline(pts2(:,:,i2),'color','g')
end



function dists = max_endpt_dist(endpts,gtpts)
d1 = XY2distances(squeeze(endpts(:,1,:))',gtpts(:,1)');
d2 = XY2distances(squeeze(endpts(:,2,:))',gtpts(:,2)');
dists = sqrt(max(d1,d2))/norm(diff(gtpts,1,2));


function ind_mask = get_pairwise_inds(inds1,inds2,not_too_far)
a = double(inds1(:));
b = double(inds2(:));
ind_mask = (a*b')>0;
ind_mask = (ind_mask.*not_too_far);


function X = merge_features(part1,part2)
feats1 = part1.unary_features;
feats2 = part2.unary_features;
