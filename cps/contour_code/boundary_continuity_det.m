function [bnd_map_o cntrs contours, jc] = boundary_continuity_det(seg_bnds)

% parameters for ends of contours
cnt_rng = 10;
pr_rng = 0.25;
% cos_sgm = 0.3;

% show flattest curves
c_th = 0.3;
l_th = 60;
ov_th = 0.8;
  


[cntrs bl b2s] = seg_boundary2(seg_bnds.classes_k);
nr_c = size(cntrs,1);

msl = seg_bnds.msl;
sx = seg_bnds.sx;
sy = seg_bnds.sy;

bnd_idx_a = sub2ind([msl msl], b2s(:,1), b2s(:,2));
[bu iu ju] = unique(bnd_idx_a);
nr_b = length(bu);

jju = zeros(msl^2,1);
jju(bu) = [1:length(bu)]';

% junction detection
ic = im2col(seg_bnds.classes_k, [2 2], 'sliding');
jc = []; bnd_segs = [];
ss = 1;
[x y] = meshgrid(1:sy-1, 1:sx-1); 
x = x(:); y = y(:);
for s = 1:(sx-1)*(sy-1)
  bs = unique(ic(:,s));
  if length(bs) >= 3
    jc(ss,1:2) = [x(s) y(s)];
    bnd_segs(ss,1:3) = bs(1:3)';
    ss = ss+1;
  end
end

% for each junction: detect supporting segment boundaries
pts_jc = [];
bnd_ep = zeros(nr_b,2);
for s = 1:size(jc,1)
  bs = bnd_segs(s,:);
  bs = [bs bs(1)];
  pt = {};
  for m = 1:3
    s1 = bs(m);
    s2 = bs(m+1);
    if s2 < s1
      t = s1; s1 = s2; s2 = t;
    end
      
    ss = sub2ind([msl msl], s1, s2);
    ik = find(bnd_idx_a == ss);
    sss = sum(bsxfun(@minus, cntrs(ik,[2 1]), jc(s,:)).^2,2);
    [sv si] = sort(sss);
    r1 = min(length(si),cnt_rng);
    r2 = max(r1, ceil(pr_rng*length(si)));
    si = si(1:r2);
    
    pts_jc(s).pt{m} = cntrs(ik(si), [2 1]);
    pts_jc(s).bl(m) = ss;
    
    % boundary end points
    s3 = jju(ss);
    if s3 > 0
      if(bnd_ep(s3,1) == 0)
        bnd_ep(s3,1) = s;
      else
        bnd_ep(s3,2) = s;
      end
    end
  end
end

% for each two boundaries at a junction: compute continuity
BS = zeros(nr_b);
for s = 1:size(jc,1)
  for m = 1:3
    p1 = pts_jc(s).pt{m};
    if m == 3, m1 = 1; else m1 = m+1; end
    p2 = pts_jc(s).pt{m1};
    if size(p1,1) < 3 | size(p2,1) < 3
      continue;
    end
    
    np = min(size(p1,1), size(p2,1));
   
    p1t = p1(1:np,:);
    p2t = p2(1:np,:);

    if(1)
      % angle between lines, which approximate the ends of 
      % two boundaries
      np1 = p1t - repmat(jc(s,:),size(p1t,1),1);
      np1 = normalize_vectors(np1);
      np1 = mean(np1,1); np1 = np1/norm(np1);
      
      p2tt = p2t(end:-1:1,:);
      np2 = p2tt - repmat(jc(s,:),size(p2tt,1),1);
      np2 = normalize_vectors(np2);
      np2 = mean(np2,1); np2 = np2/norm(np2);
      
      b1 = robustfit2(p1t);
      b1 = b1(2:3); b1 = b1/norm(b1);
      b2 = robustfit2(p2t);
      b2 = b2(2:3); b2 = b2/norm(b2);
      
      b1_1 = [b1(2) -b1(1)];
      if b1_1*np1' < 0
        b1_1 = -b1_1;
      end
      b2_1 = [b2(2) -b2(1)];
      if b2_1*np2' < 0
        b2_1 = -b2_1;
      end
      np1 = b1_1; np2 = b2_1;
      
      
      a = sum(np1.*np2);
      % exp(-(1 + a)/cos_sgm)
      % e1 = 1 - exp(-(1 + a)/cos_sgm);
      e1 = 1 + a;
    
      
    end
    
    if e1 < 0.001;
      e1 = 0.001;
    end
    
    BS(jju(pts_jc(s).bl(m)), jju(pts_jc(s).bl(m1))) = e1;
  end
end

%%% segment boundary properties:
% length
b_len = zeros(nr_b,1);
for s = 1:nr_b
  b_len(s) = length(find(bnd_idx_a == bu(s)));
end
% overlap
if(1)
  th_pb = 0.1;
  imc = seg_bnds.imconts_soft;
  imc(imc > th_pb) = 1;
  imc(imc <= th_pb) = 0;
end
imc = seg_bnds.imconts;
st = strel('disk', 2);
imcd = imdilate(imc, st);
ind_c = sub2ind([sx sy], cntrs(:,1), cntrs(:,2));
b_ov = zeros(nr_b,1);
for s = 1:nr_b
  ii = find(bnd_idx_a == bu(s));
  % b_ov(s) = sum(imc(ind_c(ii)))/b_len(s);
  b_ov(s) = sum(imcd(ind_c(ii)));
end
%%%

ik = find(b_len > 5);
nr_k = length(ik);

BS = BS - diag(diag(BS));
BS = max(BS, BS');

% shortest path in terms of number of hops in the boundary graph
BS_c = BS; 
BS_c(BS_c > 0) = 1;

[D P]=all_shortest_paths(sparse(BS_c),struct('algname','floyd_warshall'));

[ci szs] = components(sparse(BS));
[mv mi] = max(szs);
ikk = find(ci == mi);

% for each two boundaries: find the max continuity along
% the path connecting them
a_paths = {};
l_paths = zeros(nr_b);
BS_max = zeros(nr_b);
OV = zeros(nr_b);
for ii = 1:nr_b %length(ikk)
  for kk = ii+1:nr_b %length(ikk)
    % i = ikk(ii); k = ikk(kk);
    i = ii; k = kk;
    p=[]; j = k;
    while j~=0, 
      if length(p) >= 1 & j == p(end)
        break;
      end
      p(end+1)=j; 
      j=P(i,j); 
    end; 
    if length(p) <= 1
      continue;;
    end
    p=fliplr(p);
    
    a_paths{i,k} = p;
    l_paths(i,k) = sum(b_len(p));
    jj = sub2ind([nr_b nr_b], p(1:end-1), p(2:end));
    BS_max(i,k) = max(BS(jj));
    OV(i,k) = sum(b_ov(p))/sum(b_len(p));
  end
end
BS_max = max(BS_max, BS_max');
l_paths = max(l_paths, l_paths');
OV = max(OV, OV');

if(1)
  
  [pb_t pe_t] = find(BS_max < c_th & l_paths > l_th & OV > ov_th);
  ii = find(pb_t - pe_t < 0);
  pb_t = pb_t(ii);
  pe_t = pe_t(ii);


  no_ov = zeros(length(pb_t), nr_b);
  for s = 1:length(pb_t)
    p = a_paths{pb_t(s), pe_t(s)};
    no_ov(s, p) = 1;
  end
  
  lp = sum(no_ov,2);
  no_ov_n = no_ov(lp == max(lp),:);
  for s = max(lp)-1:-1:1
    f = find(lp == s);
    for m = 1:length(f)
      u = no_ov_n - repmat(no_ov(f(m), :), size(no_ov_n,1),1);
      if max(min(u,[],2)) == -1
        no_ov_n = [no_ov_n; no_ov(f(m), :)];
      end
    end
  end
  no_ov = no_ov_n;
  
  ind_c = sub2ind([sx sy], cntrs(:,1), cntrs(:,2));
  
  % t = zeros(sx,sy);
  contours = [];
  [x y] = find(imc);
  iind = find(imc);
  paths = {}; 
  for s = 1:size(no_ov,1)
    % p = a_paths{pb(s), pe(s)};
    p = find(no_ov(s,:));
    t = seg_bnds.imconts;
    pts_t = []; ind_t = []; 
    for ss = 1:length(p)
      jj = find(bnd_idx_a == bu(p(ss)));
      % t(ind_c(jj)) = t(ind_c(jj))+1;
      t(ind_c(jj)) = 3 + imc(ind_c(jj));
      pts_t = [pts_t; cntrs(jj, [2 1])];
      ind_t = [ind_t; jj];
    end
    
    % idx = annquery([y x]', pts_t', 1);
    [ddd idx] = min(dist2([y x], pts_t));
    
    nrms_t = [seg_bnds.im_nrm_x(iind(idx)) seg_bnds.im_nrm_y(iind(idx))];

    contours(s).pts = pts_t;
    contours(s).nrms = nrms_t;
    contours(s).ind = ind_t;
    
    paths{s} = p;
    
  end
  
  if(1)
    % fixing polarity to each contour
    nr_jc = size(jc,1);
    SC = zeros(msl); SC(bu) = 1; SC = max(SC, SC'); SC = sparse(SC);
    for s = 1:length(contours)
      p = paths{s};
      b = bnd_ep(p,:);
      b = b(:); b = b(b > 0); o = ones(length(b),1);
      t = sparse(b, o, o, nr_jc, 1);
      c_ep = find(t == 1); % ends of contour
      
      s_ep = bnd_segs(c_ep,:); s_ep = s_ep(:); % segments touching ends
      
      [s1 s2] = ind2sub([msl msl], bu(p));
      ss = [s1; s2]; ss = unique(ss); % segments around this
                                      % contour + end junctions
      
      s_end_junct = setdiff(s_ep, ss); % segments touching only end
                                       % junctions but not contours
      s_cnt = setdiff(ss, s_end_junct); %segments touching contour
      
      % connected components among segments touching the contour
      SC_t = SC; SC_t(bu(p)) = 0; SC_t = min(SC_t, SC_t');
      SC_t = SC_t(s_cnt, s_cnt);
      [ci szs] = components(SC_t);
      
      if 0 %length(szs) ~= 2
        fprintf('wrong connected component size %d in contour %d\n.', ...
                length(szs), s);
      end
      
      % setting polarity right
      t = zeros(sx, sy);
      cl1 = s_cnt(ci == 1);
      for k = 1:length(cl1)
        t(seg_bnds.classes_k == cl1(k)) = 1;
      end
      cl2 = s_cnt(ci == 2);
      for k = 1:length(cl2)
        t(seg_bnds.classes_k == cl2(k)) = 2;
      end
      
      p1 = contours(s).pts + 2*contours(s).nrms; 
      p1(p1 < 1) = 1; p1(p1(:,1) > sy,1) = sy; p1(p1(:,2) > sx,:) = sx;
      p1 = round(p1); ind1 = sub2ind([sx sy], p1(:,2), p1(:,1));
      
      nrms1 = contours(s).nrms;
      nrms1(t(ind1) == 2,:) = -nrms1(t(ind1) == 2,:);
      nrms2 = -nrms1;
      
      contours(s).nrms1 = nrms1;
      contours(s).nrms2 = nrms2;
      
    end
    
  end
end

if(0)
BS_k = D(ik,ik);
ind = find(BS_k);
% [sv si] = sort(BS_k(ind));
[s1 s2] = ind2sub([nr_k nr_k], ind);
s1 = bu(ik(s1)); s2 = bu(ik(s2)); v = BS_max(ind);
BSS = sparse(s1, s2, v, msl^2, msl^2);
BSS = max(BSS, BSS');
end

ind_c = sub2ind([sx sy], cntrs(:,1), cntrs(:,2));
bnd_map = zeros(sx, sy);
bnd_map(ind_c) = jju(bnd_idx_a);
bnd_map_o = zeros(sx, sy);
bnd_map_o(ind_c) = bnd_idx_a;


