function V = normalize_vectors(V, p)

% function V = normalize_vectors(V)
% Normalizes the rows of V to have Lp norm equal to 1
% 

if ~exist('p', 'var')
  p = 2;
end

n = (sum(V.^p, 2)).^(1/p)+eps;
V = V./repmat(n, 1, size(V,2));
