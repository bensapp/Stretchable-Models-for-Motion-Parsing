function computeHandDetectors(ex,opts)

load handdetector.mat skinmodel flowmodel

skin_filt = reshape(skinmodel.w(1:end-1),skinmodel.dims(1:2));
flow_filt = reshape(flowmodel.w(1:end-1),flowmodel.dims(1:2));

[skin,flow] = ex2features(ex,opts);

skin = imresize(skin,skinmodel.heatmapdims,'bilinear');
flow = imresize(flow,flowmodel.heatmapdims,'bilinear');
thetas = linspace(0,360,25);
thetas = thetas(1:end-1)*pi/180;

resp_skin = filter_all_rotations(skin,skin_filt,thetas);
resp_flow = filter_all_rotations(flow,flow_filt,thetas);

%suppres out of image
img = imread(ex.imgfile);
oob_mask = double(~any(blurimg(imresize(img,skinmodel.heatmapdims,'nearest'),11)==0,3));
resp_skin = bsxfun(@times,resp_skin,oob_mask);
resp_flow = bsxfun(@times,resp_flow,oob_mask);

resp_skin_max = max(resp_skin,[],3);
resp_flow_max = max(resp_flow,[],3);

[~,filestem] = fileparts(ex.imgfile);
savefile = sprintf('%s/handdets/%s.mat',opts.datadir,filestem);
mkdir2(savefile)
save(savefile,'resp_skin','resp_flow','resp_skin_max','resp_flow_max');


function [skin,fmcropped] = ex2features(example,opts)
[~,filestem] = fileparts(example.imgfile);
skin = loadvar(sprintf('%s/cps-features/%s_fg_color_detmaps.mat',opts.datadir,filestem),'face_color');
skin = scale01(skin);

flow = loadvar(sprintf('%s/flow/%s.mat',opts.datadir,filestem),'flow');
fm = sqrt(sum(flow.^2,3));
dx = imfilter(fm,[-1 1],'symmetric','same');
dy = imfilter(fm,[-1 1]','symmetric','same');
m = sqrt(dx.^2 + dy.^2);

flow_scale = size2(m,[1 2])./example.imgdims_orig(1:2);
fmcropped = extractWindow(m,box2rhull(example.cropbox*mean(flow_scale)));

function results = filter_all_rotations(map,filter,thetas)
nori = length(thetas);
results = zeros([size(map) nori]);
for k=1:nori
    theta = thetas(k);
    filter_rot = imrotate(filter,-theta*180/pi);
    results(:,:,k) = imfilter(map,filter_rot,'symmetric');
end
