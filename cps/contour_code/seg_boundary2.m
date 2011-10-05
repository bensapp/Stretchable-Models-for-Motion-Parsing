function [cntrs bnd_label bnd2seg bndr_seg_ind] = seg_boundary2(segs)

[x, y] = size(segs);

% getting boundaries
segs_big = zeros(2*x-1, 2*y-1);
segs_big(1:2:end, 1:2:end) = segs;
bnds_big = abs(imfilter(segs_big, [1 0 -1])) + abs(imfilter(segs_big, [1; 0; -1])); 
b1 = bnds_big(1:2:end, 2:2:end);
b2 = bnds_big(2:2:end, 1:2:end);
xb = min([size(b1,1), size(b2,1)]);
yb = min([size(b1,2), size(b2,2)]);
bnds = b1(1:xb,1:yb) + b2(1:xb,1:yb);
bnds(bnds > 0) = 1;

[xb, yb] = find(bnds > 0);
cntrs = [xb yb];

xbu = xb + 1;
xbl = xb - 1;
ybl = yb - 1;
ybr = yb+1;

ii = find(xbu > 0 & xbu <= x);
l1 = NaN(length(xb),1);
ind = sub2ind([x y], xbu(ii), yb(ii));
l1(ii) = segs(ind);

ii = find(xbl > 0 & xbu <= x);
l2 = NaN(length(xb),1);
ind = sub2ind([x y], xbl(ii), yb(ii));
l2(ii) = segs(ind);

ii = find(ybl > 0 & ybl <= y);
l3 = NaN(length(xb),1);
ind = sub2ind([x y], xb(ii), ybl(ii));
l3(ii) = segs(ind);

ii = find(ybr > 0 & ybr <= y);
l4 = NaN(length(xb),1);
ind = sub2ind([x y], xb(ii), ybr(ii));
l4(ii) = segs(ind);


% Detection of the two neighbouring segments for each boundary point
ll = [l1 l2 l3 l4];
bnd2seg = zeros(length(xb),2);
for i = 1:size(ll,1)
    p = unique(ll(i,:));
    if length(p) == 1
        p(2) = p(1);
    end
    sp = sort(p(1:2));
    bnd2seg(i,:) = sp;
end


% Detection of all boundary points per pair of segments
sl = unique(segs);
segs_nr = max(sl);  


bndr_seg_ind = sub2ind([segs_nr segs_nr], bnd2seg(:,1), bnd2seg(:,2));


% Detection of all boundary points of a segment
for j = 1:length(sl)
    [s i] = find(ll == sl(j));
    s = unique(s);
    bnd_label{sl(j)} = s;
end


if (0)
disp('spline fitting...');
pts_per_bp = 5;
for i = 1:length(cntrs)
  i
  cntr_t = cntrs{i};
  bp = ceil(size(cntr_t,1)/pts_per_bp);
  pp = spfit(cntr_t(:,1) , cntr_t(:,2), 0:bp-1);
  keyboard;
end
end


