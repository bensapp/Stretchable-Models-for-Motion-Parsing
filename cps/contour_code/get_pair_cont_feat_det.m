function [F_cs F_cm] = get_pair_cont_feat_det(sel_l1, l1, sel_l2, ...
    l2, seg_bnds, ang_th)

nr_l1 = length(sel_l1);
nr_l2 = length(sel_l2);

n3 = length(ang_th);
F_cs = zeros(nr_l1, nr_l2, n3, n3);
F_cm = zeros(nr_l1, nr_l2, n3, n3);

jj1 = find(arrayfun(@(x)(~isempty(x.bnd)), sel_l1));
mv1 = max(arrayfun(@(x)(max(x.bnd)), sel_l1(jj1)));
jj2 = find(arrayfun(@(x)(~isempty(x.bnd)), sel_l2));
mv2 = max(arrayfun(@(x)(max(x.bnd)), sel_l2(jj2)));
mv3 = max(mv1, mv2);

ul1_all = get_bnd_ind_2(sel_l1, l1, ang_th);
ul2_all = get_bnd_ind_2(sel_l2, l2, ang_th);

iii1 = arrayfun(@(x)(isempty(x.u)), ul1_all);
iii1 = reshape(1-iii1, nr_l1, length(ang_th));
ii1 = find(sum(iii1,2) > 0);

iii2 = arrayfun(@(x)(isempty(x.u)), ul2_all);
iii2 = reshape(1-iii2, nr_l2, length(ang_th));
ii2 = find(sum(iii2,2) > 0);

if isempty(ii2) || isempty(ii1), return; end

v1 = {}; v2 = {};
vp12 = {}; vp22 = {};
l1 = length(ii1);
inx1 = 1;
for kk1 = 1:l1
    k1 = ii1(kk1);
    for d1 = 1:n3
        u1 = ul1_all(k1, d1).u;
        p1 = ul1_all(k1, d1).p1;
        p2 = ul1_all(k1, d1).p2;
        v1_t = ones(length(u1),1)*sub2ind([l1 n3], kk1, d1);
        v1{inx1} = v1_t(:); v2{inx1} = u1(:);
        vp12{inx1} = p1(:);
        vp22{inx1} = p2(:);
        inx1 = inx1+1;
    end
end
v1 = cell2mat(v1'); v2 = cell2mat(v2');
vp12 = cell2mat(vp12');
vp22 = cell2mat(vp22');

U1 = sparse(v1, v2, ones(size(v1)), inx1-1, mv3);
P11t = sparse(v1, v2, vp12, inx1-1, mv3);
P12t = sparse(v1, v2, vp22, inx1-1, mv3);

v21 = {}; v22 = {};
vp12 = {}; vp22 = {};
l2 = length(ii2);
inx2 = 1;
for kk2 = 1:l2
    k2 = ii2(kk2);
    for d2 = 1:n3
        u2 = ul2_all(k2, d2).u;
        p1 = ul2_all(k2, d2).p1;
        p2 = ul2_all(k2, d2).p2;
        v2_t = ones(length(u2),1)*sub2ind([l2 n3], kk2, d2);
        v21{inx2} = v2_t(:); v22{inx2} = u2(:);
        vp12{inx2} = p1(:);
        vp22{inx2} = p2(:);
        inx2 = inx2+1;
    end
end
v21 = cell2mat(v21'); v22 = cell2mat(v22');
vp12 = cell2mat(vp12');
vp22 = cell2mat(vp22');

U2 = sparse(v21, v22, ones(size(v21)), inx2-1, mv3);
P21t = sparse(v21, v22, vp12, inx2-1, mv3);
P22t = sparse(v21, v22, vp22, inx2-1, mv3);


[ki1 di1] = ind2sub([l1 n3], [1:l1*n3]);
[ki2 di2] = ind2sub([l2 n3], [1:l2*n3]);

P11 = zeros(l1*n3, l2*n3, mv3);
P12 = zeros(l1*n3, l2*n3, mv3);
P21 = zeros(l1*n3, l2*n3, mv3);
P22 = zeros(l1*n3, l2*n3, mv3);
U12 = zeros(l1*n3, l2*n3, mv2);
for m = 1:mv2
    t = U1(:,m)*U2(:,m)';
    U12(:,:,m) = t;
    P11(:,:,m) = repmat(P11t(:,m), 1, l2*n3).*t;
    P12(:,:,m) = repmat(P12t(:,m), 1, l2*n3).*t;
    
    P21(:,:,m) = repmat(P21t(:,m)', l1*n3, 1).*t;
    P22(:,:,m) = repmat(P22t(:,m)', l1*n3, 1).*t;
end

sg1 = sign(P11.*P21);
P11 = P11.*sg1;
P21 = P21.*sg1;

sg2 = sign(P12.*P22);
P12 = P12.*sg2;
P22 = P22.*sg2;


A1 = 0.5*(P11 + P21);
A2 = 0.5*(P12 + P22);
A = cat(3, A1, A2);
[mv mi] = max(A, [], 3);

[y x] = meshgrid(1:l2*n3, 1:l1*n3);
ind = sub2ind([l1*n3 l2*n3 2*mv3],  x(:), y(:), mi(:));
P1c = cat(3, P11, P12);
P2c = cat(3, P21, P22);

min1 = 0.5*(P1c(ind) + P2c(ind) - abs(P1c(ind) - P2c(ind)));

feat1 = reshape(mv, [l1 n3 l2 n3]);
feat2 = reshape(min1, [l1 n3 l2 n3]);

feat1 = permute(feat1, [1 3 2 4]);
feat2 = permute(feat2, [1 3 2 4]);

F_cs(ii1, ii2, :,:) = feat1;
F_cm(ii1, ii2, :,:) = feat2;

if(0)
    % debug
    max(abs(F_cs(:) - F_cs1(:)))
    max(abs(F_cm(:) - F_cm1(:)))
    
    o1 = sub2ind([l1 n3], kk1, d1);
    o2 = sub2ind([l2 n3], kk2, d2);
end


if(0)
    for kk1 = 1:length(ii1)
        k1 = ii1(kk1);
        for d1 = 1:n3
            u1 = ul1_all(k1, d1).u;
            p11 = ul1_all(k1, d1).p1;
            p12 = ul1_all(k1, d1).p2;
            for kk2 = 1:length(ii2)
                k2 = ii2(kk2);
                for d2 = 1:n3
                    u2 = ul2_all(k2,d2).u;
                    p21 = ul2_all(k2,d2).p1;
                    p22 = ul2_all(k2,d2).p2;
                    
                    [jj jj1 jj2] = intersect(u1,u2);
                    if ~isempty(jj)
                        
                        % k3 = (n3)*(d1-1) + d2;
                        sn1 = sign(p11(jj1)).*sign(p21(jj2)); %both coverage
                        %scores should be non-zero
                        sn2 = sign(p12(jj1)).*sign(p22(jj2));
                        pj1 = [p11(jj1).*sn1 p21(jj2).*sn1];
                        pj2 = [p12(jj1).*sn2 p22(jj2).*sn2];
                        % pj1 = 0.5*(p11(jj1) + p21(jj2)).*sn1;
                        % pj2 = 0.5*(p12(jj1) + p22(jj2)).*sn2;
                        p = [pj1; pj2];
                        [mv mi] = max(sum(p,2)*0.5);
                        [mmv] = min(p, [],2);
                        
                        F_cs(k1,k2,d1,d2) = mv;
                        F_cm(k1,k2,d1,d2) = mmv(mi);
                    end
                end
            end
        end
    end
    
end


if(0)
    k1 = 1;
    k2 = 45;
    ul1 = ul1_all(k1).u;
    ul2 = ul2_all(k2).u;
    
    u = intersect(ul1,ul2);
    
    figure(11); imagesc(seg_bnds.imconts);
    hold on;
    plot_vecs(sel_l1(k1).pts, '.g');
    hold off;
    
    figure(14); imagesc(seg_bnds.imconts);
    hold on;
    plot_vecs(sel_l2(k2).pts, '.g');
    hold off;
    
    % show all contours:
    cnt = seg_bnds.contours;
    for m = 1:length(cnt)
        m
        figure(16); imagesc(seg_bnds.imconts);
        hold on;
        plot_vecs(cnt(m).pts, '.g');
        quiver(cnt(m).pts(:,1), cnt(m).pts(:,2), cnt(m).nrms1(:,1),  cnt(m).nrms1(:,2));
        hold off;
        pause;
    end
    
end


function ul1_all = get_bnd_ind_2(sel_l1, l1, ang_th);

p_th = 0.15;

nr_l1 = length(sel_l1);
ul1_all = [];
for k1 = 1:nr_l1
    for s1 = 1:length(ang_th)
        a1 = ang_th(s1);
        aa = sel_l1(k1).angles_all;
        sgn = sel_l1(k1).angles_sign;
        % b = sel_l1(k1).bnd(ik);
        b = sel_l1(k1).bnd;
        
        p1 = zeros(length(b),1); p2 = zeros(length(b),1);
        % p1 = zeros(mv3,1); p2 = zeros(mv3,1);
        ik1 = find(aa < a1 & ~isnan(aa) & sgn > 0);
        ik2 = find(aa < a1 & ~isnan(aa) & sgn < 0);
        
        for s = 1:length(b)
            p1(s) = length(find(sel_l1(k1).cntr_ind(ik1) == b(s)))/l1;
            p2(s) = length(find(sel_l1(k1).cntr_ind(ik2) == b(s)))/l1;
        end
        p1(p1 > 1) = 1; p2(p2 > 1) = 1;
        if max(p1) < p_th & max(p2) < p_th
            b = []; p1 = []; p2 = [];
        end
        ul1_all(k1,s1).u = b;
        ul1_all(k1,s1).p1 = p1;
        ul1_all(k1,s1).p2 = p2;
    end
end
