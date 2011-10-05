function img = blurimg(img,kernelsz)
% function img = blurimg(img,kernelsz)
if nargin < 2, kernelsz = 3; end

if mod(kernelsz,2) == 0, kernelsz=kernelsz+1; end
sigma = (kernelsz/2 - 1)*0.3 + 0.8;
h = fspecial('gaussian',kernelsz,sigma);
img = imfilter(img,h,'replicate','same');


