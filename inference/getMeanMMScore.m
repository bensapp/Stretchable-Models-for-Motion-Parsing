function [meanScore] = getMeanMMScore(treenodes, max_marginals)
MINVAL = -1e250;
mms = cat(1,max_marginals.max_marginal);
meanScore = mean(mms(mms>MINVAL));
