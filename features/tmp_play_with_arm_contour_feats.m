%% prepped clips
clear all
clips=load2('~/armps/clips_step2_max30.mat','clips')
opts=load2('~/armps/clips_step2_max30.mat','opts')
opts.state_dir = '/het/projects/ps-cascade-arms/output-step2-armstate_infos-fixed';
opts.edge_dir = '/het/projects/ps-cascade-arms/output-step2-edgeInfo-fixed';
opts.alpha = 0.8;
opts.num_parts = 6;

exind = 15;
clipind = 13;
example = clips(clipind).examples(exind);
state_infos = loadClipStatesEdges(clips(clipind), opts)
relb_pts = ind2pts(state_infos(6*exind-2).dims, state_infos(6*exind-2).states);
rwri_pts = ind2pts(state_infos(6*exind).dims, state_infos(6*exind).states);
pts1 = double(relb_pts(1:2,:));
pts2 = double(rwri_pts(1:2,:));

%% form contours from pb

% contour parameters
params.support_factor = 0.2;
params.width_factor = 0.11;
params.reg_smpl = 0.5;
params.nr_evs_emb_feats = 30;
params.ang_th = [10 20 30];

[filestem] = getFeatureFileStem(example)
seg_bnds = load2([filestem '_contour_data.mat'],'seg_bnds');

%%
tic
% seg_bnds.imconts = double(seg_bnds.imconts_soft > 0.075);
[bnd_map cntrs contours junctions] = boundary_continuity_det(seg_bnds);
toc




%% form line segments, discluding ones far from contours and too long
trainidx = 1:8;
lengths = computeLowerArmLengths(clips(trainidx));
% lengths = computeUpperArmLengths(clips(trainidx));
s  = (state_infos(1).dims([2 1])./state_infos(1).imgdims([2 1]))';

%pruning parameters
maxarmlength = quantile(lengths,0.9) .* mean(s);
minarmlength = quantile(lengths,.2)*mean(s); 
cdistlimit = 0.05*state_infos(1).dims(1);

%armlength
Darmlength = sqrt(XY2distances(pts1',pts2'));

%iterate over contours.  For each, see if both endpots are close enough to
%it
for i=1:length(contours)
    cpts = bsxfun(@times,cat(1,contours(i).pts)',s);
    
    [~,pts1dist2cont] = annquery(cpts,pts1,1);
    [~,pts2dist2cont] = annquery(cpts,pts2,1);
    pts1dist2cont_ok = pts1dist2cont <= cdistlimit;
    pts2dist2cont_ok = pts2dist2cont <= cdistlimit;
    cdist(i).dist2cont_ok = (double(pts1dist2cont_ok(:))*double(pts2dist2cont_ok(:)'));
end
dist2cont_ok = sum(cat(3,cdist.dist2cont_ok),3)>0;

vbi = Darmlength<maxarmlength & Darmlength>minarmlength & dist2cont_ok;
[inds1,inds2] = find(vbi);

linesegs = {};
linesegs{1} = pts1(:,inds1);
linesegs{2} = pts2(:,inds2);
imsc(imresize(imread(ex2file(example)),[80 80]))
hold on
line([linesegs{1}(1,:); linesegs{2}(1,:)],[linesegs{1}(2,:); linesegs{2}(2,:)])
cptsall = bsxfun(@times,cat(1,contours.pts)',s);
myplot(cptsall,'w.')

%% get cptsall, nrmall
s  = (state_infos(1).dims([2 1])./state_infos(1).imgdims([2 1]))';
cptsall = bsxfun(@times,cat(1,contours.pts)',s);
nrmall = cat(1,contours.nrms1)';

% %quantize the cpts:
% cptsall = floor(cptsall)+1;
% [~,inds] = unique(cptsall','rows');
% 
% cptsall = cptsall(:,inds);
% nrmall = nrmall(:,inds);

myplot(cptsall,'g.'), hold on, axis ij equal
myquiver(cptsall,nrmall)

%{
cla, myplot(contours(2).pts'), axis ij, hold on
myquiver(contours(2).pts',contours(2).nrms1'*10)
%}

%% for each line, find matching points and record matching as feature
nlines = length(linesegs{1});
alphas = linspace(0,1,11);
% profile on
% progbar(0,nlines)
counts = zeros(nlines,1);
lens = zeros(nlines,1);
tic
for i=1:nlines
%     i
    lpts = [linesegs{1}(:,i) linesegs{2}(:,i)];
    mdpt = mean(lpts,2);
    v0 = lpts(:,1) - lpts(:,2);
    linlen = norm(v0);
    v = v0/linlen;
    
    lpts_alpha = bsxfun(@times,lpts(:,1),[alphas; alphas]) + bsxfun(@times,lpts(:,2),1-[alphas; alphas]);
    
    dotprods = nrmall'*v;
    sign_change = 0;
    close_angle_inds = find(abs(dotprods)<0.2);
    D = sqrt(XY2distances(cptsall(:,close_angle_inds)',lpts_alpha')) < cdistlimit;
    
    close_dist_inds = find(any(D,2));
    close_inds = close_angle_inds(close_dist_inds);
    
    ptsi = cptsall(:,close_inds);
    if length(close_inds) > 2
        
        %vertical line check
        if all(ptsi(1,1)==ptsi(1,:))
            pts_line = [ptsi([1 1]); min(ptsi(2,:)) max(ptsi(2,:))];
        else
            X = [ptsi(1,:)' ones(length(close_inds),1)];
            ab = X\ptsi(2,:)';
            pts_line = [X(:,1)'; (X*ab)'];
        end
    end
    
    
    
    counts(i) = length(close_inds);
    lens(i) = norm(v0./s);
    
    if 0
        imsc(imresize(imread(ex2file(example)),[80 80]))
        hold on
        myplot(lpts,'w-','linewidth',4)
        myplot(cptsall(:,close_inds),'m.','markersize',30)
        myplot(pts_line,'g-','linewidth',2)
        drawnow
%         pause
    end
    
%     
% progbar(i,nlines)    
end
toc

%% see if it makes sense
iou = 2*min(counts,lens)./(counts+lens);
score = 0.5*counts./lens;
[~,order] = sort(score,'descend')


imsc(imresize(imread(ex2file(example)),[80 80]))
        hold on



for i=1:20
        
        lpts = [linesegs{1}(:,order(i)) linesegs{2}(:,order(i))];
        myplot(lpts,'w-','linewidth',1)       
        
end

        myplot(cptsall,'m.','markersize',20)
        drawnow

%%

tic
imc = double(seg_bnds.imconts_soft>0.05);
sx = continfo.sx;
sy = continfo.sy;
t = zeros(sx, sy);
ti = sub2ind([sx sy], cntrs(:,1), cntrs(:,2));
t(ti) = 1;
st = strel('disk', 2);
td = imdilate(imc, st);
imct = t.*td;
cntr_map = imct.*bnd_map;


seg_bnds.imconts_seg = imct;
seg_bnds.contours = contours;
seg_bnds.bnd_map = bnd_map;
seg_bnds.cntr_map = cntr_map;

name2ind = @(name)(strcmp({state_info.name},name));
si_lu = state_info(name2ind('luarm'));
si_ll = state_info(name2ind('llarm'));

[sel_r_lu sel_l_lu hp_l_u pl_u] = get_arm_features_det(si_lu,seg_bnds, ...
    params,cntr_map);
tic

%%


[y,x] = find(continfo.imconts_soft>0.05)

imsc(ex2file(example))
hold on
plot(x,y,'.')