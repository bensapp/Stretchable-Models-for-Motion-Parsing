function [V,lambda,X_mean]=computePCA_eigenvectors(X,d);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

[n,k]=size(X);
%}

[S,X_mean]=computeCovariance(X);
is_d=nargin>=2 && ~isempty(d);

if is_d && size(S,1)>5 %far small dimensions, use eig
    options=compute_options(size(S,1),d);
    S=double(S);
    result = eigs_optimized(S,[],d,options);
    V=result.X;
    lambda=result.lambda;
%     [V,lambda]=eigs(S);
%     lambda=diag(lambda);
else
    [V,lambda]=eig(S);
    lambda=diag(lambda);
end
[lambda,ind]=sort(lambda,'descend');
V=V(:,ind);
% lambda=lambda(end:-1:1);
% V=V(:,end:-1:1);

if is_d
    V=V(:,1:d);
    lambda=lambda(1:d);
end

function options=compute_options(n,nbEigenvectors);
options.issym = 1;
options.maxit = 100;
options.maxit = 500;
options.tol = 1e-3;% 1e-3; 1e-4; 1e-2

options.v0 = ones(n,1);
options.p = nbEigenvectors*2;

if nbEigenvectors==1
    options.p = 3;
end
options.p = min(round(options.p),n);

options.fastMode = 1;
options.computeX = 1;
options.warningConvergence = 1;
options.sigma = 'LA';
options.n = n;

assert(nbEigenvectors<=options.p-1 && nbEigenvectors>0);
