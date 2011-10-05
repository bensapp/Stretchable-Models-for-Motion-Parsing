function [max_marginals minmax] = computeSumMaxMarginals(mmarg_info)

% zero out marginals
max_marginals = mmarg_info(1).max_marginals;
for k = 1:numel(max_marginals)
    max_marginals(k).max_marginal = zeros(size(max_marginals(k).max_marginal));
end

% add in valid marginals ONLY
for j = 1:numel(mmarg_info)
    for k = 1:numel(max_marginals)
        max_marginals(k).max_marginal = max_marginals(k).max_marginal + ...
            mmarg_info(j).max_marginals(k).max_marginal;
    end
end

minmax = inf;
for k = 1:numel(max_marginals)
    minmax = min(max(max_marginals(k).max_marginal));
end
            