function [f] = addBinaryContourAlignmentFeatures(treenode, parent, valid_binary_inds,datadir)

% form contours from pb
[~,fstem] = fileparts(treenode.imgfile);
filepath = sprintf('%s/cps-features/%s_contour_data.mat',datadir,fstem);
seg_bnds = loadvar(filepath,'seg_bnds');
contours = loadvar(filepath,'contours');

% optionally suppress via optical flow
filepath = sprintf('%s/flow/%s.mat',datadir,fstem);
flow = loadvar(filepath,'flow');

% lots of contours if the image was cropped with a part outside the image,
% create an image-vs-blackness strong contour boundary
contours = remove_boundary_artifact_contours(contours,treenode);

contours_flow = suppress_contours_optflow(contours,flow,treenode.imgdims);

f_noflow = contour_alignment(treenode,parent,valid_binary_inds,contours,0);

if isempty(contours_flow), 
    f_flow = sparse(size(f_noflow,1),size(f_noflow,2)); 
else
    f_flow = contour_alignment(treenode,parent,valid_binary_inds,contours_flow,0);
end


f = [f_noflow f_flow];


function f = contour_alignment(treenode,parent,valid_binary_inds,contours,display)


pts1 = double(ind2pts(treenode.dims, treenode.states));
pts2 = double(ind2pts(parent.dims, parent.states));
pts1 = pts1(1:2,:);
pts2 = pts2(1:2,:);


%% form line segments, discluding ones far from contours and too long
scale  = (treenode.dims([2 1])./treenode.imgdims([2 1]))';
if isequal(parent.name(2:end),'larm') && isequal(treenode.name(2:end),'hand')
    armlens = loadvar('arm_lengths_for_contours.mat','larm');
elseif isequal(parent.name(2:end),'uarm') && isequal(treenode.name(2:end),'larm')
    armlens = loadvar('arm_lengths_for_contours.mat','uarm');
else
    error('invalid binary combo!')
end
minarmlength = armlens.minarmlength*mean(scale);
maxarmlength = armlens.maxarmlength*mean(scale);
cdistlimit = 0.075*mean(treenode.dims(1:2));

%armlength
Darmlength = sqrt(XY2distances(pts1',pts2'));

if 1
    %iterate over contours.  For each, see if both line seg endpts are close enough to
    %it.  Discard line segs which are not close enough to any contour.
    for i=1:length(contours)
        cpts = bsxfun(@times,cat(1,contours(i).pts)',scale);
        [~,pts1dist2cont] = annquery(cpts,pts1,1);
        [~,pts2dist2cont] = annquery(cpts,pts2,1);
        pts1dist2cont_ok = pts1dist2cont <= cdistlimit;
        pts2dist2cont_ok = pts2dist2cont <= cdistlimit;
        cdist(i).dist2cont_ok = (double(pts1dist2cont_ok(:))*double(pts2dist2cont_ok(:)'));
    end
    dist2cont_ok = sum(cat(3,cdist.dist2cont_ok),3)>0;
else
    %same, but merge all contours, discarding contour identity
    cpts = bsxfun(@times,cat(1,contours.pts)',scale);
    [~,pts1dist2cont] = annquery(cpts,pts1,1);
    [~,pts2dist2cont] = annquery(cpts,pts2,1);
    pts1dist2cont_ok = pts1dist2cont <= cdistlimit;
    pts2dist2cont_ok = pts2dist2cont <= cdistlimit;
    dist2cont_ok = (double(pts1dist2cont_ok(:))*double(pts2dist2cont_ok(:)'));
end

vbi = Darmlength<maxarmlength & Darmlength>minarmlength & dist2cont_ok;
[inds1,inds2] = find(vbi);

linesegs = {};
linesegs{1} = pts1(:,inds1);
linesegs{2} = pts2(:,inds2);

if 0
    %%
    imsc(imread(ex2file(treenode)))
    hold on
    l1 = [linesegs{1}(1,:); linesegs{2}(1,:)];
    l2 = [linesegs{1}(2,:); linesegs{2}(2,:)];
    l1 = bsxfun(@times,l1,1./scale);
    l2 = bsxfun(@times,l2,1./scale);
    line(l1,l2)
    cptsall = bsxfun(@times,cat(1,contours.pts)',1);
    myplot(cptsall,'w.')
end

%% get cptsall, nrmall
cptsall = bsxfun(@times,cat(1,contours.pts)',scale);
nrmall = cat(1,contours.nrms1)';

%% for each line, find matching points and record matching as feature
nlines = size(linesegs{1}, 2);
alphas = linspace(0,1,5);
% profile on
% progbar(0,nlines)
counts = zeros(nlines,1);
lens = zeros(nlines,1);
%disp2('nlines')
% tic
for i=1:nlines
%     i
    lpts = [linesegs{1}(:,i) linesegs{2}(:,i)];
    v0 = lpts(:,1) - lpts(:,2);
    linlen = norm(v0);
    v = v0/linlen;
    
    lpts_alpha = bsxfun(@times,lpts(:,1),[alphas; alphas]) + bsxfun(@times,lpts(:,2),1-[alphas; alphas]);
    
    dotprods = nrmall'*v;
    sign_change = 0;
    close_angle_inds = find(abs(dotprods)<0.2);
    D = (XY2distances(cptsall(:,close_angle_inds)',lpts_alpha')) < (cdistlimit*cdistlimit);
    
    close_dist_inds = find(any(D,2));
    close_inds = close_angle_inds(close_dist_inds);
    
    ptsi = cptsall(:,close_inds);
    
    % fit straight line:
    if 0 && length(close_inds) > 2
        
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
    lens(i) = norm(v0./scale);
    
    if 0
        imsc(imresize(imread(ex2file(treenode)),[80 80]))
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
% toc

scores = 0.5*counts./lens;

%% make into sparse feature matrix
nbins = 10;
vbeidx = find(vbi);
[~,bins] = fastdiscretize(scores, nbins);
f = sparse(vbeidx, bins, true, numel(vbi), nbins);

missed = valid_binary_inds & ~vbi;
missedidx = find(missed);
f = [f sparse(missedidx, ones(numel(missedidx),1), true, numel(vbi), 1)];

0;

function contours2 = remove_boundary_artifact_contours(contours,treenode)
%%
cropbox = compute_crop_boundary(treenode);
thresh = 7;
contours2 = contours;
for i=1:length(contours2)
    p = contours2(i).pts';
    badidx = abs(p(1,:) - cropbox(1)) < thresh | abs(p(1,:) - cropbox(3)) < thresh | abs(p(2,:) - cropbox(2)) < thresh | abs(p(2,:) - cropbox(4)) < thresh; 
    contours2(i).pts = contours2(i).pts(~badidx,:);
    contours2(i).nrms = contours2(i).nrms(~badidx,:);
    contours2(i).ind = contours2(i).ind(~badidx,:);
    contours2(i).nrms1 = contours2(i).nrms1(~badidx,:);
    contours2(i).nrms2 = contours2(i).nrms2(~badidx,:);
end

%throw away contours without many pts:
contours2 = contours2(cellfun(@length,{contours2.pts})>10);
0;
if 0
    %% display
    ex2file(treenode)
    imsc(ex2file(treenode))
    hold on
    myplot(cat(1,contours.pts)')
    myplot(cat(1,contours2.pts)','go')
    plotbox(cropbox,'w-')
    0;
    drawnow
end

function cropbox = compute_crop_boundary(example)
img = imread(example.imgfile);
%% autocrop
img(1,1,:) = cat(3,0,0,0);
imgind = rgb2ind(img,64);
mask = ~(imgind==imgind(1));
mask  = imerode(mask,strel('disk',3));
% mask = ~all(bsxfun(@eq,img,c),3);
minx = find(any(mask),1,'first');
maxx = find(any(mask),1,'last');
miny = find(any(mask,2),1,'first');
maxy = find(any(mask,2),1,'last');
cropbox = round(boxinbounds([minx-1 miny-1 maxx+1 maxy+1],example.imgdims));


function contours_flow = suppress_contours_optflow(contours,flow,imgdims)
%% suppresses by removing contour points far from any flow discontinuities


fm = sqrt(sum(flow.^2,3));
dx = imfilter(fm,[-1 1],'symmetric','same');
dy = imfilter(fm,[-1 1]','symmetric','same');
m = sqrt(dx.^2 + dy.^2);

%%
mblur = blurimg(double(m>0.1),9)>0;

scale = (size2(mblur,[2 1])./imgdims([2 1]))';
for i=1:length(contours)
    
    pts = round(bsxfun(@times,contours(i).pts',scale));
    pts = max(pts,1);
    pts(1,:) = min(pts(1,:),size(mblur,2));
    pts(2,:) = min(pts(2,:),size(mblur,1));
    
    inds = sub2ind(size2(mblur,[1 2]),pts(2,:),pts(1,:));
    ison = mblur(inds);
    
    contours_flow(i).pts = contours(i).pts(ison,:);
    contours_flow(i).nrms = contours(i).nrms(ison,:);
    contours_flow(i).nrms1 = contours(i).nrms1(ison,:);
    contours_flow(i).nrms2 = contours(i).nrms2(ison,:);
    contours_flow(i).ind = [];
    contours_flow(i).npts = sum(ison);

    if 0
        
        imsc(mblur), colormap gray
        hold on
        myplot(pts)
        myplot(pts(:,ison),'mo')
        pause
        
    end
end

% cull empty/weak contours:
contours_flow = contours_flow([contours_flow.npts]>10);
0;
