function [inds] = pts2ind(sz, pts)
% INDS = pts2ind(SIZE, PTS)

if length(sz)==2
    inds = sub2ind(sz, pts(2,:), pts(1,:));
elseif length(sz)==3
    inds = sub2ind(sz, pts(2,:), pts(1,:), pts(3,:));
else
    error(['pts2nd only works in 2 or 3 dimensions, not ',num2str(length(pq))]);
end
    


