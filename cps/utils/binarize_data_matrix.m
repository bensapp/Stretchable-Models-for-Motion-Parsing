function B = binarize_data_matrix(X0,nvals,minval,maxval)
% for now, thresholds each feature i = X0(:,i) into evenly spaced vals
% between min and max, or, between specified minval and maxval

if nargin > 2
    X = X0;
    tvals = linspace(minval,maxval,nvals+2);
else
    X = zscore(X0);
    tvals = linspace(min(X(:)),max(X(:)),nvals+2);
end
tvals = tvals(2:end-1);

nfeats = size(X,2);
nex = size(X,1);
B = sparse(nex,(nvals+1)*nfeats);
B(:,1:nfeats) = sparse(X <= tvals(1));

for t=2:length(tvals)
    Bt = X > tvals(t-1) & X <= tvals(t);
    B(:,(t-1)*nfeats+1:t*nfeats) = sparse(Bt);
end
B(:,nvals*nfeats+1:end) = sparse(X>tvals(end));
