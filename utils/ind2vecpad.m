function [X] = ind2vecpad(idx, nrow, ncol)
% like ind2vec, but adds padding if necessary

X = ind2vec(idx(:)');
nc = size(X,2);
nr = size(X,1);

if nr ~= nrow
    X = vertcat(X, sparse(zeros(nrow-nr, nc)));
end

if nargin > 2 && nc ~= ncol
    X = horzcat(X, sparse(zeros(nrow, ncol-nc)));
end
