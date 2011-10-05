function D = color_track_sparse_pts(pts1,pts2,vbe,img1,img2,bsize,nbColors,method)
% function l0_track_sparse_pts(pts1,pts2,img1,img2,bsize,method)
% Supports inter- and intra-time computations.  For a single frame, simply
% pass in img2 = [] or img2 = img1
%
% method can be either 'chi2' or 'l0'

if 0
    %% unit test
    
    img1 = imread(ex2file(clips(8).examples(150)));
    img2 = imread(ex2file(clips(8).examples(155)));
    
    
    pts1 =[
       50.239       32.848       45.086       69.562       160.38       177.77       153.94       176.48       254.42       174.55
       204.36       185.68       170.86       196.63       90.352        91.64       67.164         63.3       206.93       179.88
       ];
    
    pts2 = [];
    for i=1:size(pts1,2)
        pts2 = [pts2 bsxfun(@plus,pts1(:,i),10*randn(2,30))];
    end
    
    % who's responsible for computing valid binary inds?
    vbe = (sqrt(XY2distances(pts1',pts2'))<80);
    
    
    %%
    
    bsize = 30;
    nbColors = 32;
    dists = color_track_sparse_pts(pts1,pts2,vbe,img1,img2,bsize,nbColors,'chi2');
    
    [vals,closest_pt2_inds] = min(dists,[],2);
    
    while 1
        imsc(img1)
        hold on
        myplot(pts1,'g.','markersize',40)
        myplot(pts2,'wo')
        myquiver(pts1,pts2(:,closest_pt2_inds)-pts1)
        pause(0.5)
        
        imsc(img2)
         hold on
        myplot(pts1,'g.','markersize',40)
        myplot(pts2,'wo')
        myquiver(pts1,pts2(:,closest_pt2_inds)-pts1)
                pause(0.5)

        
    end
    
    %%
    load tmpdbg.mat pts1 pts2 vbe img1 img2 bsize nbColors method
    
    
    tic
    color_track_sparse_pts(pts1,pts2,vbe,img1,img2,bsize,nbColors,'L0');
    toc
end

% nbColors = 32;
if isempty(img2)
    [labels1,cmap]=rgb2ind(img1,nbColors,'nodither');
    labels2 = labels1;
else
    [labels1,labels2,cmap]=compute_color_labels_image_pair(img1,img2,nbColors);
end

n1 = size(pts1,2);
n2 = size(pts2,2);
patches1 = get_img_patches(pts1,labels1,bsize);
patches2 = get_img_patches(pts2,labels2,bsize);

F1 = reshape(patches1,bsize*bsize,n1);
F2 = reshape(patches2,bsize*bsize,n2);
[indi,indj] = find(vbe);
switch lower(method)
    case 'chi2'
        h1 = sum_to_1(histc(F1,1:nbColors),1);
        h2 = sum_to_1(histc(F2,1:nbColors),1);
        H = [h1 h2];
        dists = mex_indij2distances_fun('chi2',H,indi,n1+indj,0);
    case 'l0'
        F = single([F1 F2]);
        dists = mex_indij2distances_fun('L0',F,indi,n1+indj,0);
        % put b/w zero and one:
        dists = dists/size(F,1);
    otherwise
        error('wtf distance function is this?!?')
end

D = 1000*ones(n1,n2);
D(vbe) = dists;

function res = get_img_patches(pts,img,bsize)
boxes = box_from_dims(bsize,bsize,pts);
p = extractWindow(img,box2rhull(boxes(1,:)));
res = zeros([size(p) size(boxes,1)],'uint8');
for i=1:size(boxes,1)
    p = extractWindow(img,box2rhull(boxes(i,:)));
%     p = extractBox(img,boxes(i,:),false);
    res(:,:,i) = p;
end