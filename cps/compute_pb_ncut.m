function [time_pb,time_ncut,time_postprocess] = compute_pb_ncut(opts,pars)
%% pb, ncut parameters
if nargin < 2
    pars.max_img_sz = 500;
    pars.max_pb_sz = 500;
    pars.nr_eigenvectors = 30;
    pars.nr_superpixels = 150;
end

img = im2double(imread(opts.imgfile));

%% pb
t0 = clock;
pbfile = fullfile(opts.outputdir,[opts.filestem,'_pb.mat']);
if ~exist(pbfile,'file') || opts.force_precompute
    compute_pb(img,opts,pars);
end
time_pb = etime(clock,t0);

%% ncut
t0 = clock;
ncutfile = fullfile(opts.outputdir,[opts.filestem,'_ncut.mat']);
if ~exist(ncutfile,'file') || opts.force_precompute
    compute_ncut(img,opts,pars);
end
time_ncut = etime(clock,t0);

%% post-process segmentation
t0 = clock;
contourfile = fullfile(opts.outputdir,[opts.filestem,'_contour_data.mat']);
if ~exist(contourfile,'file') || opts.force_precompute
    sg = []; sg.X = load2(ncutfile,'X');
    pb = []; pb.th_map = load2(pbfile,'th_map');
    [K seg_bnds]= extract_img_features_pbbased(sg, pb, pars.nr_eigenvectors);
    [~,~,contours] = boundary_continuity_det(seg_bnds);
    save(contourfile, 'K', 'seg_bnds','contours');
end
time_postprocess = etime(clock,t0);



function compute_pb(img,opts,pars)
fprintf('   extract PB contours ...\n');

if  max(size(img)) > pars.max_img_sz
    g = fspecial('gaussian', [10 10], 0.8);
    img = imfilter(img, g);
    img = imresize(img, pars.max_pb_sz/max(size(img)), 'nearest');
    img = img - min(img(:));
    img = img/max(img(:));
end


rsz = 1;
if max(size(img)) > pars.max_img_sz
    rsz = pars.max_img_sz/max(size(img));
end

[mPb_nmax, mPb_nmax_rsz, bg1, bg2, bg3, cga1, cga2, cga3, ...
    cgb1, cgb2, cgb3, tg1, tg2, tg3, textons, th_map, mPb_all] = ...
    multiscalePb(img, rsz);

savefile_pb = fullfile(opts.outputdir,[opts.filestem,'_pb.mat']);
save(savefile_pb, 'mPb_nmax', 'mPb_nmax_rsz', 'mPb_all', 'th_map');

function compute_ncut(img,opts,pars)
fprintf('   segment image ...\n');
[sx_orig sy_orig ch_orig] = size(img);
if max(size(img)) > pars.max_img_sz
    sigma = 0.2;
    g = fspecial('gaussian', ceil(2*5*sigma*[1 1]), sigma);
    img1 = imfilter(img, g);
    img2 = imresize(img1, pars.max_img_sz/max(size(img)));
else
    img2 = img;
end
img2(img2 < 0) = 0;
img2(img2 > 1) = 1;


options.pb_file = fullfile(opts.outputdir,[opts.filestem,'_pb.mat']);
options.sample_rate = 1;
[classes,X,lambda, Xorig,D,Xr,W] = ncut_multiscale(img2,pars.nr_eigenvectors,options);

0;
%%
image = img2;
[sx_seg sy_seg ch_seg] = size(image);

% get superpixels by discretizing and oversegmenting
Sp = refine_seg(classes, X, pars.nr_superpixels);

savefile_ncut = fullfile(opts.outputdir,[opts.filestem,'_ncut.mat']);
save(savefile_ncut, 'classes','X','Sp',...
    'lambda', 'image', 'sx_orig', 'sy_orig', 'sx_seg', ...
    'sy_seg');

function [K seg_bnds]= extract_img_features_pbbased(sg, pb, ne);

% load(fn_seg);
% load(fn_pb);

Xr = sg.X(:,:,1:ne);

% extract edges
[imconts_cnt p1 n1 E1 X_s imconts_soft] = seg_cont(Xr);
  
classes = discretisation(Xr);
classes_k = prune_segments_size2(classes, 40);
[cntrs bnd_label bnd2seg bndr_seg_ind] = ...
    seg_boundary2(classes_k);
pts = cntrs(:, [2 1]);

imconts = zeros(size(classes));
ind = sub2ind(size(classes), pts(:,2), pts(:,1));
imconts(ind) = 1;
bnd1 = zeros(size(classes));
bnd1(ind) = bnd2seg(:,1);
bnd2 = zeros(size(classes));
bnd2(ind) = bnd2seg(:,2);
[sx sy] = size(imconts);
  
% prune fake edges
[x1 y1] = find(imconts_cnt);
ind_cnt = find(imconts_cnt);
pts_cnt = [y1 x1];
% nrm_cnt = normals(pts_cnt);
th = pb.th_map(ind_cnt) + pi/2; th = th(:);
nrm_cnt = [cos(th) sin(th)];
[imconts_cnt im_nrm_cnt_x im_nrm_cnt_y] = ptsnrm_pts2map(imconts_cnt, ...
                                                  pts_cnt, nrm_cnt);

% provide soft mask
[x1 y1] = find(imconts_soft);
ind_cnt_s = find(imconts_soft);
pts_cnt_s = [y1 x1];
th_s = pb.th_map(ind_cnt_s) + pi/2; th_s = th_s(:);
nrm_cnt_s = [cos(th_s) sin(th_s)];
imconts_cnt_s = zeros(size(imconts_soft));
imconts_cnt_s(ind_cnt_s) = 1;
[imconts_cnt_s im_nrm_x_soft im_nrm_y_soft] = ...
    ptsnrm_pts2map(imconts_cnt_s, pts_cnt_s, nrm_cnt_s);

if size(pts_cnt,1) > 3
  % [idx2 dst2] = annquery(pts_cnt', pts', 1);
  [dst1 idx1] = min(dist2(pts_cnt, pts));

  imconts_pruned = zeros(sx, sy);
  imconts_pruned(ind(dst1 < 2)) = 1;
else
  imconts_pruned = imconts;
end

% nrm2 = normals(pts);
ind_pr = find(imconts_pruned);
th = pb.th_map(ind_pr) + pi/2; th = th(:);
nrm2 = [cos(th) sin(th)];
[y1 x1] = find(imconts_pruned);
[imconts im_nrm_x im_nrm_y] = ptsnrm_pts2map(imconts, [x1 y1], nrm2);

% [pts_sp nrms_sp] = subpixel_cntrs(pts, E1(:,:,1));

seg_bnds.sx =sx;
seg_bnds.sy =sy;

seg_bnds.imconts = imconts_pruned;
seg_bnds.im_nrm_x = im_nrm_x;
seg_bnds.im_nrm_y = im_nrm_y;

seg_bnds.imconts_soft = imconts_soft;
seg_bnds.im_nrm_x_soft = im_nrm_x_soft;
seg_bnds.im_nrm_y_soft = im_nrm_y_soft;

seg_bnds.imconts_cnt = imconts_cnt;
seg_bnds.im_nrm_cnt_x = im_nrm_cnt_x;
seg_bnds.im_nrm_cnt_y = im_nrm_cnt_y;

% seg_bnds.pts_sp = pts_sp;
% seg_bnds.nrms_sp = nrms_sp;

seg_bnds.bnd1 = bnd1.*imconts_pruned;
seg_bnds.bnd2 = bnd2.*imconts_pruned;
seg_bnds.classes_k = classes_k;

% construct kernel
seg_bnds.base_im = classes_k;

Xr_sh = reshape(Xr, [sx*sy ne]);
msl = ne;
D_s = zeros(msl, ne);
for k = 1:msl
  if ~isempty(find(classes_k == k))
    D_s(k,:) = mean(Xr_sh(classes_k == k,:));
  end
end
D_s = normalize_vectors(D_s);
seg_bnds.D_s = D_s;
seg_bnds.msl = msl;
% seg_bnds.X = Xr;
% K = D_s*cl_centers';
K = D_s*D_s';

if(0)
  
  figure(10); imagesc(imconts_cnt); colormap gray;
hold on; quiver(pts_cnt(:,1), pts_cnt(:,2), nrm_cnt(:,1), nrm_cnt(:,2));
axis image;

figure(11); imagesc(imconts_pruned); colormap gray;
%hold on; quiver(x1(:), y1(:), nrm2(:,1), nrm2(:,2));
axis image;

  keyboard;
end