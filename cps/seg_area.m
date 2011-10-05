function A = seg_area(segs, nr_segs)

% 
% A = seg_area(segs)
% 
% Computes the area of each segment
%

if ~exist('nr_segs', 'var')
  nr_segs = max(segs(:));
end

A = zeros(nr_segs,1);
for k = 1:nr_segs
  A(k) = length(find(segs == k));
end