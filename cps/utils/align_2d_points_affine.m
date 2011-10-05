function A = align_2d_points_affine(x,y)
% minimizes ||y - A*x|| by using unconstrained least squares fit
npts = size(x,2);
b=[x' ones(npts,1)];
X = [b zeros(size(b)); zeros(size(b)) b];
r = [y(1,:)'; y(2,:)';];
u = X\r;

A = reshape(u,3,2)';

0;

