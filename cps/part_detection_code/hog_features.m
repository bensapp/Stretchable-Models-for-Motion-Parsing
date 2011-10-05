function f=hog_features(img,cellsize)
% cellsize is the size of a HOG cell - it should be even.

if nargin == 1
    cellsize = 4;
end

img = im2double(img);

%must be r,g,b image
assert(size(img,3)==3);
%cell size must be even
assert(rem(cellsize,2)==0)

[h,w,z] = size(img);
newsize = round([h w]/cellsize)-2;


f = mex_hog_features(img,cellsize);

assert(isequal(newsize,size2(f,[1 2])))

