function cntrs = seg_boundary(segs)

% 
% cntrs = seg_boundary(segs)
% 
% Get segment boundaries
% Input:
%   segs - M X N matrix of segments (each pixel contains the label index
%   for its segment)
% Output:
%   cntrs - P x 2 matrix of all boundarie coordinates; each boundary point
%   saved as a row; first coordinate is a row coordinate
% 
% toshev@google.com
% 

[x, y] = size(segs);

% getting precise boundaries
segs_big = zeros(2*x-1, 2*y-1);
segs_big(1:2:end, 1:2:end) = segs;
bnds_big = abs(imfilter(segs_big, [1 0 -1])) + abs(imfilter(segs_big, [1; 0; -1])); 
b1 = bnds_big(1:2:end, 2:2:end);
b2 = bnds_big(2:2:end, 1:2:end);
xb = min([size(b1,1), size(b2,1)]);
yb = min([size(b1,2), size(b2,2)]);
bnds = b1(1:xb,1:yb) + b2(1:xb,1:yb);
bnds(bnds > 0) = 1;

[xb, yb] = find(bnds > 0);
cntrs = [xb yb];


