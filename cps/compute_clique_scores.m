function ps = compute_clique_scores(ps,lw)
if nargin == 1
    for i=1:length(ps)
        lw.part(i).unary_w = ps(i).unary_w;
        lw.part(i).binary_w = ps(i).binary_w;
    end
end
for i=1:length(ps)
    nstates_i = length(ps(i).states);
    ps(i).log_unary_clique = compute_clique_score_unary(ps(i).unary_features, lw.part(i).unary_w);
    if ~ps(i).parent, continue, end
    nstates_ip = length(ps(ps(i).parent).states);
    [ps(i).log_binary_clique,ps(i).valid_binary_inds] = ...
        compute_clique_score_binary(ps(i).binary_features, lw.part(i).binary_w,nstates_i, nstates_ip);
end

function out = compute_clique_score_unary(X,w)
out = vec(X*w(:));

function [out,v] = compute_clique_score_binary(X,w,n1,n2)
assert(issparse(X))
out = X*w;
out = reshape(out,n1,n2);

%not-too-far feature is the last feature - make valid binary inds matrix
%from this
ntf = X(:,end);
v = reshape(ntf,n1,n2);
