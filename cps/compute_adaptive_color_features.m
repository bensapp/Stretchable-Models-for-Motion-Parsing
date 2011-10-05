function feats = compute_adaptive_color_features(opts,state_info)

detmapfile = fullfile(opts.outputdir,[opts.filestem,'_fg_color_detmaps.mat']);
if ~exist(detmapfile,'file') || opts.force_precompute
    compute_color_detmaps(opts,state_info);
end
detmaps = load2(detmapfile,'detmaps');

% unary features
for i=1:length(state_info)
    d = detmaps(strcmp(state_info(i).name,{detmaps.name})).detmap;
    f = [];
    for j=1:length(d)
        d{j} = resize_detmap(d{j},state_info(i).state_dims);
        f = [f d{j}(state_info(i).states)];
    end
    feats(i).unary_features = f;
    feats(i).name = state_info(i).name;
end
feats(i).binary_features = [];


function compute_color_detmaps(opts,state_info)

fgbgdata = load2('fgbg_region_data.mat');
img = imresize(imread(opts.imgfile),fgbgdata.imgdims,'nearest');

face_color = fgbg_to_color_map(img,fgbgdata.bg_mask,fgbgdata.fg_face);
torso_color = fgbg_to_color_map(img,fgbgdata.bg_mask,fgbgdata.fg_torso);

face_color = imresize(face_color,state_info(1).state_dims(1:2));
torso_color = imresize(torso_color,state_info(1).state_dims(1:2));

angles = get_articulated_angles(state_info(1).state_dims(3));
for p=1:length(state_info)
    detmaps(p).name = state_info(p).name;
    detmaps(p).detmap{1} = get_rectagle_counts(face_color,state_info(p).dims.*[0.8 0.5],angles);
    detmaps(p).detmap{2} = get_rectagle_counts(torso_color,state_info(p).dims.*[0.8 0.5],angles);
end

detmapfile = fullfile(opts.outputdir,[opts.filestem,'_fg_color_detmaps.mat']);
save(detmapfile,'detmaps','face_color','torso_color');


function scores = fgbg_to_color_map(img,negmask,box)
pts = box2pts(box);
dims = size(img);
posinds = sub2ind(dims,pts(2,:),pts(1,:));
neginds = find(negmask);
scores = {};

Xall = img2features(img);
Xall = zscore([Xall Xall.^2 ones(size(Xall,1),1)]);

X = [Xall(posinds,:);Xall(neginds,:)];

y = ([true(length(posinds),1);false(length(neginds),1)]);

nrounds = 10;
mdlfile = sprintf('tmp_color_classifier_%s.xml',uid(8));
mex_opencv_boosting('train',X,2*int32(y)-1,mdlfile,nrounds,2);
s = mex_opencv_boosting('test',Xall,[],mdlfile,nrounds);
delete(mdlfile);
scores = reshape(sum(s,2),dims(1:2));


function feats = img2features(img)
img = reshape(img,prod(size2(img,[1 2])),1,3);
rgb = cat(1,img);
lab = rgb2lab_2(rgb);
hsv = rgb2hsv(rgb);
ycbcr = rgb2ycbcr(rgb);
f = @(x)(squeeze(double(x)));
feats = [f(rgb) f(lab) f(hsv) f(ycbcr)];

function results = get_rectagle_counts(map,dims,thetas)
nori = length(thetas);
results = zeros([size(map) nori]);
dims = round(dims);
filter = sum_to_1(ones(dims));
for k=1:nori
    theta = thetas(k);
    filter_rot = imrotate(filter,-theta*180/pi);
    res = imfilter(map,filter_rot,'symmetric');

    %calculate shifts
    shift_vec = dims(1)/2*rotatePts([0;-1],theta,[0;0]);

    res_shifted = shiftmat(res,flipud(shift_vec)',min(res(:)));
    results(:,:,k) = res_shifted;
end

0;