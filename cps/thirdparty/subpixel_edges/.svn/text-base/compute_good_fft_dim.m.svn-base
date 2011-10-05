function p_best = compute_good_fft_dim(p);
% Timothee Cour
% GRASP Lab, University of Pennsylvania, Philadelphia
% Date: 28-Jul-2006 09:15:41
% DO NOT DISTRIBUTE

% p_best=2^ceil(log2(p));
% return;
pmax = 2^ceil(log2(p));
p_best = p;
for k=p:pmax
    z = factor(k);
    if (all(z<=5) && sum(z~=2)<=2)
%     if (all(z<=3) && sum(z~=2)<=2)
        p_best = k;
        return;
    end
end

