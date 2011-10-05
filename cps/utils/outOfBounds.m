function v = outOfBounds(dims,pts)
% function v = outOfBounds(dims,pts)
%WARNING: each row r of pts needs to correspond to dims(r)
ndims = size(pts,1);
if length(dims) < ndims
    dims  = [dims ones(1,ndims - length(dims))];
end
v = false(1,size(pts,2));
for d=1:size(pts,1)
    v = v | pts(d,:) < 1 | pts(d,:) > dims(d);
end