function [emag_norm, edge_variance_map] = normalize_emap_local(emag, edge_variance_scale, radius, thres_small_mag)
%
% normalize emag by local maximum in a sqaure neighborhood
%


se = strel('square', radius);
emag_norm = zeros(size(emag));
for k = 1:size(emag, 3);
    mag1 = emag(:,:,k);
    mag1(find(mag1 <= thres_small_mag)) = 0;
    edge_variance_map = imdilate(mag1, se) * edge_variance_scale / sqrt(0.5);
    emag_norm(:, :, k) = mag1 ./ (edge_variance_map + eps);
end;

% 
% 
% emag_norm = zeros(size(emag));
% k=1;
% emagsub = emag(:, :, k);
% edge_variance=max(emagsub(:)) * edge_variance_scale/sqrt(0.5);
% emag_norm(:, :, k) = emag(:, :, k) / (edge_variance+eps);
% 
% 
% 
% for k = 2:size(emag, 3)
%     emagsub = emag(:, :, k);
%     edge_variance=max(emagsub(:)) * edge_variance_scale/sqrt(0.5);
%     emag_norm(:, :, k) = emag(:, :, k) / (edge_variance+eps);
% end;
