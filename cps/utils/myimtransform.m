function imgT = myimtransform(img,T,padval,dims,do_mirror)
% function imgT = myimtransform(img,T,padval,dims)

%TODO: allow symmetry if out of bounds

% debug case
if nargin == 0
    mex utils/mex_myimtransform.cpp
    img = rgb2gray(imread(idx2file(10000)));
    T = [     0.52532198881773         0.850903524534118         -254.384326434801
        -0.850903524534118          0.52532198881773          219.692868919846
        0                         0                         1];
    padval = 0;
    dims = [100 100];
    Tinv = inv(T);
    imgT = mex_myimtransform(double(img),Tinv,padval,int32(dims));
    imsc(imgT);
    return
end

if nargin < 3, padval = 0; end
if nargin < 4, dims = size2(img,[1 2]); end
if nargin < 5, do_mirror = 0; end
if isempty(padval), padval = 0; end

if isequal(size(T),[2 3])
    T = [T; 0 0 1];
end

assert(isequal(size(T),[3 3]));
assert(all(size(img)>0))

Tinv = inv(T);
imgT = zeros([dims(1:2) size(img,3)]);
for i=1:size(img,3)
    imgT(:,:,i)= mex_myimtransform(double(img(:,:,i)),Tinv,padval,int32(dims(1:2)),double(do_mirror));
end

%  imgT = matlab_myimtransform(img,T);

function imgT = matlab_myimtransform(img,T)
if size(T,1) == 2
    T = [T; zeros(1,size(T,2))];
    T(end) = 1;
end

w=size(img,2); h=size(img,1);
[x,y] = meshgrid(1:w,1:h);
xy = [x(:)';y(:)'];
Tinv = inv(T);
xyinv = round(Tinv*[xy; ones(1,size(xy,2))]);
ok = ~outOfImageBounds(size(img),xyinv);
xyinv = xyinv(:,ok);
xy = xy(:,ok);
xyinvidx = sub2ind([size(img,1) size(img,2)],xyinv(2,:),xyinv(1,:));
xyidx = sub2ind([size(img,1) size(img,2)],xy(2,:),xy(1,:));
imgT = zeros(size(img));
for j=1:size(img,3)
    imgC = img(:,:,j);
    imgTC = imgT(:,:,j);
    imgTC(xyidx) = imgC(xyinvidx);
    imgT(:,:,j) = imgTC;
end
imgT = uint8(imgT);