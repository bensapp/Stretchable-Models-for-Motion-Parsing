function feats = compute_contour_features(opts,state_info,valid_binary_inds)

for j=1:length(state_info)
    feats(j).name = state_info(j).name;
    feats(j).unary_features = [];
    feats(j).binary_features = [];
end

%% contour parameters
params.support_factor = 0.2;
params.width_factor = 0.11;
params.reg_smpl = 0.5;
params.nr_evs_emb_feats = 30;
params.ang_th = [10 20 30];

%% load precomputed data
name2ind = @(name)(strcmp({state_info.name},name));
contourfile = fullfile(opts.outputdir,[opts.filestem,'_contour_data.mat']);
seg_bnds = load2(contourfile,'seg_bnds');
seg_bnds = load2(contourfile,'seg_bnds');
ncutfile = fullfile(opts.outputdir,[opts.filestem,'_ncut.mat']);
X = load2(ncutfile,'X');
sx = seg_bnds.sx;
sy = seg_bnds.sy;
nsegs = size(X,3);
X = reshape(X, [sx*sy, nsegs]);
X = normalize_vectors(X);
seg_bnds.X = X;



%% left arms
si_lu = state_info(name2ind('luarm'));
si_ll = state_info(name2ind('llarm'));
[ef_l_u ] = get_emb_features(si_lu,seg_bnds, ...
    params);
[ef_l_l ] = get_emb_features(si_ll, seg_bnds, ...
    params);
emb_features_left = 0.5*(1 + ef_l_u*ef_l_l');
%% right arms
si_ru = state_info(name2ind('ruarm'));
si_rl = state_info(name2ind('rlarm'));
[ ef_r_u] = get_emb_features(si_ru, seg_bnds, ...
    params);
[ef_r_l ] = get_emb_features(si_rl, seg_bnds, ...
    params);
emb_features_right = 0.5*(1 + ef_r_u*ef_r_l');

%% assign to features struct
feats(name2ind('llarm')).binary_features = vec(emb_features_left');
feats(name2ind('rlarm')).binary_features = vec(emb_features_right');


function emb_feat = get_emb_features(st_info, seg_bnds, ...
    params);

sx = seg_bnds.sx;
sy = seg_bnds.sy;
msl = seg_bnds.msl;

reg_smpl = params.reg_smpl;
nr_evs_emb_feats = params.nr_evs_emb_feats;


hpxya = double(ind2pts(st_info.state_dims,st_info.states));
angles = get_articulated_angles(st_info.state_dims(3));
a = angles(hpxya(3,:));
huv = angle2direction(a);
hp = [hpxya(1:2,:); huv]';

% hp = [st_info.hypotheses'];
sc = st_info.state_dims(1:2);
sc = [sy/sc(2) sx/sc(1)];
hp_sc = hp.*repmat([sc 1 1], size(hp,1),1);
pl_sc = st_info.dims(1)*mean(sc);

h = hp; %st_info.hypotheses;
% h = h'; h = h(si(1:3),:);
p = st_info.dims(1);

sc = st_info.state_dims(1:2);
sc = [sy/sc(2) sx/sc(1)];
h = h.*repmat([sc 1 1], size(h,1),1);
p = p*mean(sc);

hp = params.width_factor*p;

pd = h(:,3:4);
[th rd] = cart2pol(pd(:,1), pd(:,2));
po_r = [rd.*cos(th-pi/2) rd.*sin(th-pi/2)];
po_l = [rd.*cos(th+pi/2) rd.*sin(th+pi/2)];

rect = {};
% rect_supp = {};
rect_supp_l = {}; rect_supp_r = {};
emb_feat = zeros(size(h,1),nr_evs_emb_feats);
for s = 1:size(h,1)
    
    m1 = h(s,1:2);
    m2 = h(s,1:2) + h(s,3:4)*p;
    po = [h(s,4) -h(s,3)]; po = po/norm(po);
    m11 = hp*po + m1; m12 = -hp*po + m1;
    m21 = hp*po + m2; m22 = -hp*po + m2;
    m = [m11; m12; m22; m21; m11];
    rect{s} = m;
    
    
    mn = norm(m1-m2);
    mt = (m1-m2)/mn;
    mc = 0.5*(m1 + m2);
    tt = 1:ceil((1-reg_smpl)*0.5*mn);
    nt = length(tt);
    tt = [tt(:) tt(:)];
    
    e1 = repmat(mc,nt,1) + repmat(mt,nt,1).*tt;
    e2 = repmat(mc,nt,1) - repmat(mt,nt,1).*tt;
    e = [e1; e2];
    e = round(e);
    e = e(e(:,1) > 0 & e(:,1) <= sy & e(:,2) > 0 & e(:,2) <= sx,:);
    if size(e,1) == 0
        em = zeros(1, nr_evs_emb_feats);
    else
        ie = sub2ind([sx sy], e(:,2), e(:,1));
        em = mean(seg_bnds.X(ie,1:nr_evs_emb_feats), 1);
        em = em/norm(em);
    end
    emb_feat(s,:) = em;
    
end