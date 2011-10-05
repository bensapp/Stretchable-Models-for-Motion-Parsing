function seg = refine_seg(seg, X, seg_nr)

coord_w = 3;

seg_nr_c = max(seg(:));
sa = seg_area(seg, seg_nr_c);

[sx sy ch] = size(X);
if ch > 1
    X = reshape(X, sx*sy, ch);
end

[xx yy] = meshgrid(1:sy, 1:sx);
xx = xx(:); yy = yy(:);
xx = coord_w*xx/max(xx);
yy = coord_w*yy/max(yy);

X = normalize_vectors(X);
X = [X xx yy];

nr_c = 2;
while length(sa) < seg_nr
    [mv mi] = max(sa);
    ii = find(seg == mi);
    e = X(ii,:);
    [cl cc] = kmeans(e, nr_c, 10, false);
    for m = 2:nr_c
        la = length(sa) + m - 1;
        seg(ii(cl == m)) = la;
        sa(la) = length(find(cl == m));
        sa(mi) = sa(mi) - sum(sa(end-m+2:end));
    end
end
