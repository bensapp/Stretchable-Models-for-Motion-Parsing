function [sel_ind_r sel_ind_l hp_sc pl_sc] = get_arm_features_det(st_info, seg_bnds, ...
    params,img);

sx = seg_bnds.sx;
sy = seg_bnds.sy;
msl = seg_bnds.msl;

reg_smpl = params.reg_smpl;

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

hs = params.support_factor*p;
hp = params.width_factor*p;

pd = h(:,3:4);
[th rd] = cart2pol(pd(:,1), pd(:,2));
po_r = [rd.*cos(th-pi/2) rd.*sin(th-pi/2)];
po_l = [rd.*cos(th+pi/2) rd.*sin(th+pi/2)];

rect = {};
% rect_supp = {};
rect_supp_l = {}; rect_supp_r = {};
for s = 1:size(h,1)
    if(1)
        m1 = h(s,1:2);
        m2 = h(s,1:2) + h(s,3:4)*p;
        po = [h(s,4) -h(s,3)]; po = po/norm(po);
        m11 = hp*po + m1; m12 = -hp*po + m1;
        m21 = hp*po + m2; m22 = -hp*po + m2;
        m = [m11; m12; m22; m21; m11];
        rect{s} = m;
    end
    
    m11 = hs*po_r(s,:) + m1; m21 = hs*po_r(s,:) + m2;
    m = [m11; m1; m2; m21; m11];
    rect_supp_r{s} = m;
    
    m11 = hs*po_l(s,:) + m1; m21 = hs*po_l(s,:) + m2;
    m = [m11; m1; m2; m21; m11];
    rect_supp_l{s} = m;
    
    0;
end

pts_c = []; ind_c = []; nrms_c = [];
for k = 1:length(seg_bnds.contours)
    pts_c = [pts_c; seg_bnds.contours(k).pts];
    nrms_c = [nrms_c; seg_bnds.contours(k).nrms1];
    ind_c = [ind_c; ones(size(seg_bnds.contours(k).pts,1),1)*k];
end

[X Y] = meshgrid(1:5:sy, 1:5:sx);
P = [X(:) Y(:)]; pind = sub2ind([sx sy], Y(:), X(:));
sa = zeros(msl,1);
for s = 1:msl
    sa(s) = length(find(seg_bnds.classes_k(pind) == s));
end

sel = {};
sel2 = zeros(msl, length(rect));
% sel_cs = {};
sel_ind_r = []; sel_ind_l = [];
for s = 1:length(rect)
    r = rect{s}(1:4,:);
    inn = inpolygon(X, Y, r(:,1), r(:,2));
    inn = find(inn == 1);
    sat = zeros(msl,1);
    for ss = 1:msl
        sat(ss) = length(find(seg_bnds.classes_k(pind(inn)) == ss));
    end
    sat2 = sa - sat;
    jj = find(sat > sat2);
    sel{s} = jj;
    leg_i = find(sa > 0);
    sel2(leg_i,s) = sat(leg_i)./sa(leg_i);
    
    if(0)
        r = rect_supp{s}(1:4,:);
        inn = inpolygon(pcs(:,1), pcs(:,2), r(:,1), r(:,2));
        sel_cs{s} = find(inn == 1);
    end
    
    r = rect_supp_r{s}(1:4,:);
    inn = inpolygon(pts_c(:,1), pts_c(:,2), r(:,1), r(:,2));
    ij = find(inn == 1);
    
    u = unique(ind_c(ij));
    
    po = [h(s,4) -h(s,3)]; po = po/norm(po);
    pt = h(s,3:4); pt = pt/norm(pt);
    
    % t = zeros(sx,sy);
    au = zeros(length(u),1);
    aa = ones(length(ij),1)*NaN;
    sgn = zeros(length(ij),1);
    cntr_ind = zeros(length(ij),1);
    for ss = 1:length(u)
        jj1 = find(ind_c(ij) == u(ss));
        jj = ij(jj1);
        nn = nrms_c(jj,:);
        % nnt = [nn(:,2) -nn(:,1)];
        [th ro] = cart2pol(nn(:,1), nn(:,2));
        nnt = [ro.*cos(th + pi/2) ro.*sin(th + pi/2)];
        
        in = find(sum(nn.^2,2)>0);
        
        if length(in) == 0
            au(ss) = 90;
            continue;
        end
        
        dp = nnt(in,:)*pt';
        sp = sign(dp); a = abs(dp);
        a = acos(a)*180/pi;
        am = mean(a);
        au(ss) = am;
        cntr_ind(jj1) = u(ss);
        aa(jj1(in)) = a;
        sgn(jj1(in)) = sp;
        % t(jjj(in)) = a;
    end
    
    sel_ind_r(s).pts = pts_c(ij,:);
    sel_ind_r(s).bnd = u;
    sel_ind_r(s).cntr_ind = cntr_ind;
    sel_ind_r(s).angles = au;
    sel_ind_r(s).angles_all = aa;
    sel_ind_r(s).angles_sign = sgn;
    
    
    r = rect_supp_l{s}(1:4,:);
    inn = inpolygon(pts_c(:,1), pts_c(:,2), r(:,1), r(:,2));
    ij = find(inn == 1);
    
    u = unique(ind_c(ij));
    
    po = [h(s,4) -h(s,3)]; po = po/norm(po);
    
    % t = zeros(sx,sy);
    aa = ones(length(ij),1)*NaN;
    au = zeros(length(u),1);
    sgn = zeros(length(ij),1);
    cntr_ind = zeros(length(ij),1);
    for ss = 1:length(u)
        jj1 = find(ind_c(ij) == u(ss));
        jj = ij(jj1);
        nn = nrms_c(jj,:);
        [th ro] = cart2pol(nn(:,1), nn(:,2));
        nnt = [ro.*cos(th + pi/2) ro.*sin(th + pi/2)];
        
        in = find(sum(nn.^2,2)>0);
        
        if length(in) == 0
            au(ss) = 90;
            continue;
        end
        
        dp = nnt(in,:)*pt';
        sp = sign(dp); a = abs(dp);
        a = acos(a)*180/pi;
        am = mean(a);
        au(ss) = am;
        cntr_ind(jj1) = u(ss);
        aa(jj1(in)) = a;
        sgn(jj1(in)) = sp;
        % t(jjj(in)) = a;
    end
    
    sel_ind_l(s).pts = pts_c(ij,:);
    sel_ind_l(s).bnd = u;
    sel_ind_l(s).cntr_ind = cntr_ind;
    sel_ind_l(s).angles = au;
    sel_ind_l(s).angles_all = aa;
    sel_ind_l(s).angles_sign = sgn;
end
