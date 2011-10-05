function d2 = dist2(x, c)
% function d2 = dist2(x, c)
%DIST2	Calculates squared distance between two sets of points.
% x : ndata * ndim
% c : ncenter * ndim
% d2 : ndata * ncenter , d2(i, j) = |x(i)-c(j)|^2

[ndata, dimx] = size(x);
[ncentres, dimc] = size(c);

d2 = sum(x.^2, 2) * ones(1, ncentres) + ...
    ones(ndata, 1) * (sum(c.^2, 2))' - ...
    2.*(x * c');

