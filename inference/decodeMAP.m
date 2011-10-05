function [guess] = decodeMAP(armstate_infos, max_marginals)

for k = 1:numel(max_marginals)
    [mm ind] = max(max_marginals(k).max_marginal);
    guess(k) = armstate_infos(k).states(ind);
end