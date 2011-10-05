function [wavg] = addWeights(wavg, w)

% add the taley to the average
for k = 1:numel(wavg.unary_w), wavg.unary_w{k} = wavg.unary_w{k} + w.unary_w{k}; end
for k = 1:numel(wavg.binary_w), wavg.binary_w{k} = wavg.binary_w{k} + w.binary_w{k}; end
