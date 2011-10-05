function results = detect_part(model,img,thetas,angle_ids)
if nargin < 4, angle_ids = 1:length(thetas); end

if model.flipimg, img = flipdim(img,1); end

scale_search_step= 1/1.1; 
scale_search_num_levels = 11; 

results = nan([size2(img,[1 2]),length(thetas)]);

for k=angle_ids
    theta = thetas(k);
    fprintf('\tangle #%02d: %.02f degrees\n',k,theta*180/pi)
    imgr = imrotate(img,theta*180/pi,'bicubic','crop');
    detmap = get_hog_detmap(imgr,model,scale_search_step,scale_search_num_levels);
    padval = min(detmap(:));
    
    %shift so that detmap is centered around joint locations
    shift_vec = model.joint_loc;
    detmap_shifted = shiftmat(detmap,flipud(shift_vec)',padval);
	
    %rotate back
    res0 = imrotate(detmap_shifted,-theta*180/pi,'nearest','crop');
    res = res0;
    res(res == 0) = NaN;    

    results(:,:,k) = res;
end

if model.flipimg, results = flipdim(results,1); end

results(isnan(results)) = min(results(~isnan(results(:))));

function detmap = get_hog_detmap(img,model,scaling,num_levels)


hogpyr = get_hog_pyramid(img,scaling,model.hogdims,num_levels,model.cellsize);
for k=1:length(hogpyr)
    hogpyr(k).heatmap = eval_hog_boosting(hogpyr(k).hogfeat,model);
end
detmap = zeros([size2(img,1:2) length(hogpyr)]);
for i=1:length(hogpyr)
    detmap(:,:,i) = imresize(hogpyr(i).heatmap,size2(img,[1 2]));
end

% detmap = max(detmap,[],3);
detmap = mean(detmap,3);

% assert(hogpyr(1).scale==1)
% shiftvechog = -model.hogdims(2);
% shiftvec = shiftvechog / mean(size2(hogpyr(1).hogfeat,[1 2])./size2(img,[1 2]))

function heatmap = eval_hog_boosting(hfeats,model)
[feat_y,feat_x,feat_z] = ind2sub(model.hogdims,[model.classifiers.index_feature]);
thresh = [model.classifiers.thres];
lowvals = [model.classifiers.v1];
highvals = [model.classifiers.v2];
heatmap = ...
    mex_eval_hog_boosting(hfeats,...
    int32(model.hogdims),int32(feat_x), int32(feat_y), int32(feat_z), ...
    thresh,highvals,lowvals);


function hogpyr = get_hog_pyramid(img0,scaledown,hogdims,maxk,cell_size)
assert(scaledown < 1);
s = scaledown;
k=1;
img=img0;
newsize = [Inf Inf];
while k < maxk
    hogpyr(k).hogfeat = hog_features(double(img),cell_size);
    hogpyr(k).scale = s/scaledown;
    if any(size(hogpyr(k).hogfeat) < hogdims)
        hogpyr(end) = []; break;
    end
    
    k=k+1;
    img = imresize(img0,s,'bicubic');
    s=s*scaledown;
    newsize = round(size2(img,[1 2])/cell_size)-2;
end