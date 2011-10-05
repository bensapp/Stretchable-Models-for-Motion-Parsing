function feats = compute_contour_features(opts,state_info,valid_binary_inds)

for j=1:length(state_info)
    feats(j).name = state_info(j).name;
    feats(j).unary_features = [];
    feats(j).binary_features = [];
end


% contour parameters
params.support_factor = 0.2;
params.width_factor = 0.11;
params.reg_smpl = 0.5;
params.nr_evs_emb_feats = 30;
params.ang_th = [10 20 30];


contourfile = fullfile(opts.outputdir,[opts.filestem,'_contour_data.mat']);
seg_bnds = load2(contourfile,'seg_bnds');
ncutfile = fullfile(opts.outputdir,[opts.filestem,'_ncut.mat']);
X = load2(ncutfile,'X');
sx = seg_bnds.sx;
sy = seg_bnds.sy;
nsegs = size(X,3);
X = reshape(X, [sx*sy, nsegs]);
X = normalize_vectors(X);
seg_bnds.X = X;

[features_left features_right] = contour_features_release_2(seg_bnds, state_info, params);

name2ind = @(name)(strcmp({feats.name},name));
feats(name2ind('llarm')).binary_features = format_feats(features_left,valid_binary_inds(name2ind('llarm')).v);
feats(name2ind('rlarm')).binary_features = format_feats(features_right,valid_binary_inds(name2ind('rlarm')).v);;
0;

function f = format_feats(f_cell,valid_binary_inds)
fall = [];
for i=1:2
    f = permute(f_cell{i},[2 1 3]);
    f = reshape(f,size(f,1)*size(f,2),size(f,3));
    f = sparse(f);
    fall = [fall f];
end
vbi = valid_binary_inds(:);
fsparse = sparse(length(vbi),size(fall,2));
fsparse(vbi,:) = fall(vbi,:);



function [features_left features_right] = contour_features_release_2(seg_bnds, state_info, params)

sx = seg_bnds.sx;
sy = seg_bnds.sy;

imc = seg_bnds.imconts_soft;
th_c = 0.1;
imc(imc < th_c) = 0;
imc(imc >= th_c) = 1;

[bnd_map cntrs contours junctions] = boundary_continuity_det(seg_bnds);

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

[sel_r_ll sel_l_ll hp_l_l pl_l] = get_arm_features_det(si_ll, seg_bnds, ...
    params,cntr_map);


display = 0;
if display
    %%
    imsc(cntr_map), colormap gray, hold on
    colors = rand(length(contours),3)
    for i=1:length(contours)
        myplot(contours(i).pts','.','color',colors(i,:))
    end
    p = sel_l_lu;
    si = si_lu;
    angles = get_articulated_angles(24);
    s = size2(cntr_map,[1 2])./si.state_dims(1:2);
    s = fliplr(s)';
    for i=1:length(p)
        if isempty(p(i).pts), continue, end
        
        %convert state hypothesis to endpts
        statept = double(ind2pts([80 80 24],si.states(i)));
        stateuv = angle2direction(angles(statept(3)));
        joint = statept(1:2);
        endpt = joint + stateuv*si.dims(1);
        endpts = [joint endpt].*[s s];
        
        
        h1 = myplot(p(i).pts','wo','markersize',12);
        h2 = myplot(endpts,'w-','linewidth',2);
        pause
        delete(h1)
        delete(h2)
    end
end


[Fl_c Fl_c2] = get_pair_cont_feat_det(sel_l_lu, pl_u, sel_l_ll, ...
    pl_l, seg_bnds, params.ang_th);

display = 0;
if display
    %%
    imsc(cntr_map), colormap gray, hold on
    colors = rand(length(contours),3)
    for i=1:length(contours)
        myplot(contours(i).pts','.','color',colors(i,:))
    end
    scores = vec(Fl_c(:,:,1,2));
    [ignore,order] = sort(scores,'descend');
        angles = get_articulated_angles(24);
  s = size2(cntr_map,[1 2])./si_lu.state_dims(1:2);
    s = fliplr(s)';
    for i=1:length(order)
        [a,b] = ind2sub(size2(Fl_c,[1 2]),order(i));
        
        %convert state hypothesis to endpts
        statept = double(ind2pts([80 80 24],si_lu.states(a)));
        stateuv = angle2direction(angles(statept(3)));
        joint = statept(1:2);
        endpt = joint + stateuv*si_lu.dims(1);
        endpts1 = [joint endpt].*[s s];
        
        %convert state hypothesis to endpts
        statept = double(ind2pts([80 80 24],si_ll.states(b)));
        stateuv = angle2direction(angles(statept(3)));
        joint = statept(1:2);
        endpt = joint + stateuv*si_ll.dims(1);
        endpts2 = [joint endpt].*[s s];
        
    
        h1=myplot(endpts1,'w-','linewidth',5)
        h2=myplot(endpts2,'w-','linewidth',5)
        drawnow
%                 pause
        delete(h1)
        delete(h2)
        
    end
    
end

[s1 s2 s3 s4] = size(Fl_c);
Fl_c = reshape(Fl_c, [s1 s2 s3*s4]);
Fl_c2 = reshape(Fl_c2, [s1 s2 s3*s4]);

si_ru = state_info(name2ind('ruarm'));
si_rl = state_info(name2ind('rlarm'));

[sel_r_ru sel_l_ru hp_r_u pr_u] = get_arm_features_det(si_ru, seg_bnds, ...
    params);

[sel_r_rl sel_l_rl hp_r_l pr_l] = get_arm_features_det(si_rl, seg_bnds, ...
    params);

[Fr_c Fr_c2] = get_pair_cont_feat_det(sel_r_ru, pr_u, sel_r_rl, ...
    pr_l, seg_bnds, params.ang_th);


[s1 s2 s3 s4] = size(Fr_c);
Fr_c = reshape(Fr_c, [s1 s2 s3*s4]);
Fr_c2 = reshape(Fr_c2, [s1 s2 s3*s4]);


features_left = {};
features_right = {};
features_left{1} = Fl_c; %old features; you may want not
%to use them
features_left{2} = Fl_c2;

features_right{1} = Fr_c; %old contour features; you may want not
%to use them
features_right{2} = Fr_c2;



