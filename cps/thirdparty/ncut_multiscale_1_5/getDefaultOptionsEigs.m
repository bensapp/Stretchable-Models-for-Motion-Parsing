function [options,nbEigenvectors] = getDefaultOptionsEigs(n,nbEigenvectors);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

options.issym = 1;
% options.maxit = 100;
options.maxit = 500;

% options.tol = 1e-3;1e-4; 1e-2
options.tol = 1e-3;

options.v0 = ones(n,1);
%options.v0 = rand(n,1);

% options.p = nbEigenvectors*3;
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

nbEigenvectors = min(nbEigenvectors , options.p-1);
% assert(nbEigenvectors<=options.p-1 && nbEigenvectors>0);
