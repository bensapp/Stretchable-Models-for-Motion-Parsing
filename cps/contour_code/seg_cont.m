function [im pts nrms E X_s im_soft] = seg_cont(X, th)

if ~exist('th', 'var')
  th = 0.2;
end

mrg = 5;

si = 1;
g = fspecial('gaussian', [10 10]*si, si); ...
X = X./repmat(sqrt(sum(X.^2,3)), [1 1 size(X,3)]);
X = imfilter(X, g);
X_s = X;

ex = imfilter(X, [-1 1]);
ey = imfilter(X, [-1; 1]);
e = sqrt(sum(ex.^2 + ey.^2,3));
ex = sum(ex,3); ey = sum(ey,3);
ne = sqrt(ex.^2 + ey.^2);
ex = ex./(ne+eps); ey = ey./(ne+eps);
E = cat(3, e, ex, ey);


if(0)
[cla Xr] = discretisation(X);

e_all = {};
for sel_ii = 1:size(X,3);
  ex = imfilter(X(:,:,sel_ii), [-1 1]);
  ey = imfilter(X(:,:,sel_ii), [-1; 1]);
  e = sqrt(sum(ex.^2 + ey.^2,3));
  e_all{sel_ii} = e;
end
  figure; imagesc(e);
end

[sx sy ch] = size(e);
[Xr Yr] = meshgrid(1:sy, 1:sx);
  
nx1 = ex + Xr; ny1 = ey + Yr;
avals1 = avrg_val(nx1, ny1, e);
nx2 = -ex + Xr; ny2 = -ey + Yr;
avals2 = avrg_val(nx2, ny2, e);
lm = e(:) - max(avals1, avals2);
lm = reshape(lm, [sx sy]);
lm(:, 1:mrg) = 0; lm(:, end-mrg:end) = 0;
lm(1:mrg, :) = 0; lm(end-mrg:end, :) = 0;

if(0)
  st = 50;
  ls = linspace(0, 1, st);
  nrp = numel(nx1);
  nxs = repmat((nx1(:) - nx2(:)), 1, st).*repmat(ls, nrp, 1) + repmat(nx2(:), 1, st);
  nys = repmat((ny1(:) - ny2(:)), 1, st).*repmat(ls, nrp, 1) + repmat(ny2(:), 1, st);
  av_all = avrg_val(nxs, nys, e);
  av_all = reshape(av_all, nrp, st);
  [mv mi] = max(av_all, [], 2);
  ind_m = sub2ind([nrp st], [1:nrp]', mi);
end


  
im = zeros(sx, sy);
jj = find(e > th & lm > 0);
im(jj) = 1;

im_soft = zeros(sx, sy);
jj = find(e > 0.01 & lm > 0);
im_soft(jj) = e(jj);

[px py] = ind2sub([sx sy], jj);
pts = [py px];
nrms = [ex(jj) ey(jj)];

% pts2 = [nxs(ind_m(jj)) nys(ind_m(jj))];

if(0)
  im_g = imfilter(im, g);
  im_x = imfilter(im_g, [-1 1]);
  im_y = imfilter(im_g, [-1; 1]);
  nrm3 = [im_x(jj) im_y(jj)];
  nrm3 = normalize_vectors(nrm3);
end

if(0)

  nrms2 = normals(pts);
  is(e, 30);
  hold on;
  plot_vecs(pts, '.y');
  % quiver(pts(:,1),pts(:,2),nrm3(:,1),nrm3(:,2), 'g');
  quiver(pts(:,1),pts(:,2),nrms2(:,1),nrms2(:,2), 'r');
  % plot_vecs(pts2, '.g');
  hold off;

end


