function edgemap = get_canny_edgemap(I, sigma, thres)
%

% use Matlab's canny edge detector to find local maximum
% then compute the phase map according to the gradient

% Transform to a double precision intensity image if necessary
% if ~isa(I,'double') && ~isa(I,'single') 
%   I = im2single(I);
% end
I = double(I);

if nargin < 2
    sigma = 1;
end;

if nargin < 3
    thres = [];
end;


[e, Ix, Iy, dgau2D ] = my_canny(I, sigma, thres);


Ixx = imfilter(Ix, dgau2D, 'conv','replicate');
Ixy = imfilter(Ix, dgau2D', 'conv','replicate');
Iyy = imfilter(Iy, dgau2D', 'conv','replicate');



Imag = sqrt(Ix.*Ix + Iy .* Iy);
% Ixn = Ix ./ Imag ;
% Iyn = Iy ./ Imag;

Ixn = Ix ./ (Imag+eps) ;
Iyn = Iy ./ (Imag+eps);


Iphase1 = Ixn.*Ixn.*Ixx + 2*Ixn.*Iyn.*Ixy + Iyn.*Iyn.*Iyy;


Iphase = (Iphase1>0) - (Iphase1<=0);
% Iphase = Iphase1;

% remove small Iphase1


% Iphase = Iphase .* e;
% dilate
% se = strel('square',2);
% Iphase = imerode(Iphase,se);



eindex = find(e);
values = Imag(eindex);
[h, w] = size(I);


% ex = mod(eindex-1, h)+1;
% ey = eindex - (ex-1)*h;

ey = mod(eindex-1, h)+1;
ex = (eindex-ey)/h+1;


egx = Ix;
egy = Iy;
emag = Imag .* e;
%% dilate
se = strel('square',2);
edilate = imdilate(e,se);
emag = Imag .* edilate;


% emag = Imag .* edilate / max(Imag(:));
% emag(e>0) = 1;

% emag = Imag / max(Imag(:));

ephase = Iphase;
edges2 = emag.*e;


edgemap.eindex = eindex;
edgemap.values = values;
edgemap.x = ex;
edgemap.y = ey;
edgemap.gx = egx;
edgemap.gy = egy;
edgemap.emag = emag;
edgemap.ephase = ephase;
% edgemap.imageEdges = edges2;
edgemap.imageEdges = full(sparse(ey, ex, 1, h, w));


function [e,ax, ay, dgau2D]=my_canny(a, sigma, thresh)

% [a,method,thresh,sigma,thinning,H,kx,ky] = parse_inputs(varargin{:});
%   Thresh Threshold value
%   Sigma  standard deviation of Gaussian
% thresh = [];
% sigma = 1;



[m,n] = size(a);

% The output edge map:
e = false(m,n);

% Magic numbers
GaussianDieOff = .0001;
PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
ThresholdRatio = .4;          % Low thresh is this fraction of the high.

% Design the filters - a gaussian and its derivative

pw = 1:30; % possible widths
ssq = sigma^2;
width = find(exp(-(pw.*pw)/(2*ssq))>GaussianDieOff,1,'last');
if isempty(width)
    width = 1;  % the user entered a really small sigma
end

t = (-width:width);
gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq);     % the gaussian 1D filter

% Find the directional derivative of 2D Gaussian (along X-axis)
% Since the result is symmetric along X, we can get the derivative along
% Y-axis simply by transposing the result for X direction.
[x,y]=meshgrid(-width:width,-width:width);

if width > 1
    dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);
else
    gau =[1];
    dgau2D = [-1 1];
end;

% Convolve the filters with the image in each direction
% The canny edge detector first requires convolution with
% 2D gaussian, and then with the derivitave of a gaussian.
% Since gaussian filter is separable, for smoothing, we can use
% two 1D convolutions in order to achieve the effect of convolving
% with 2D Gaussian.  We convolve along rows and then columns.

%smooth the image out

% if width >= 1
    aSmooth=imfilter(a,gau,'conv','replicate');   % run the filter accross rows
    aSmooth=imfilter(aSmooth,gau','conv','replicate'); % and then accross columns
    %apply directional derivatives
    ax = imfilter(aSmooth, dgau2D, 'conv','replicate');
    ay = imfilter(aSmooth, dgau2D', 'conv','replicate');

%  else
%     [ax, ay] = gradient(a);
%  end;


mag = sqrt((ax.*ax) + (ay.*ay));
magmax = max(mag(:));
if magmax>0
    mag = mag / magmax;   % normalize
end

% Select the thresholds
if isempty(thresh)
    counts=imhist(mag, 64);
    highThresh = find(cumsum(counts) > PercentOfPixelsNotEdges*m*n,...
        1,'first') / 64;
    lowThresh = ThresholdRatio*highThresh;
    thresh = [lowThresh highThresh];
elseif length(thresh)==1
    highThresh = thresh;
    if thresh>=1
        eid = sprintf('Images:%s:thresholdMustBeLessThanOne', mfilename);
        msg = 'The threshold must be less than 1.';
        error(eid,'%s',msg);
    end
    lowThresh = ThresholdRatio*thresh;
    thresh = [lowThresh highThresh];
elseif length(thresh)==2
    lowThresh = thresh(1);
    highThresh = thresh(2);
    if (lowThresh >= highThresh) || (highThresh >= 1)
        eid = sprintf('Images:%s:thresholdOutOfRange', mfilename);
        msg = 'Thresh must be [low high], where low < high < 1.';
        error(eid,'%s',msg);
    end
end

% The next step is to do the non-maximum supression.
% We will accrue indices which specify ON pixels in strong edgemap
% The array e will become the weak edge map.
idxStrong = [];
for dir = 1:4
    idxLocalMax = cannyFindLocalMaxima(dir,ax,ay,mag);
    idxWeak = idxLocalMax(mag(idxLocalMax) > lowThresh);
    e(idxWeak)=1;
    idxStrong = [idxStrong; idxWeak(mag(idxWeak) > highThresh)];
end

if ~isempty(idxStrong) % result is all zeros if idxStrong is empty
    rstrong = rem(idxStrong-1, m)+1;
    cstrong = floor((idxStrong-1)/m)+1;
    e = bwselect(e, cstrong, rstrong, 8);
    e = bwmorph(e, 'thin', 1);  % Thin double (or triple) pixel wide contours
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : cannyFindLocalMaxima
%
function idxLocalMax = cannyFindLocalMaxima(direction,ix,iy,mag)
%
% This sub-function helps with the non-maximum supression in the Canny
% edge detector.  The input parameters are:
%
%   direction - the index of which direction the gradient is pointing,
%               read from the diagram below. direction is 1, 2, 3, or 4.
%   ix        - input image filtered by derivative of gaussian along x
%   iy        - input image filtered by derivative of gaussian along y
%   mag       - the gradient magnitude image
%
%    there are 4 cases:
%
%                         The X marks the pixel in question, and each
%         3     2         of the quadrants for the gradient vector
%       O----0----0       fall into two cases, divided by the 45
%     4 |         | 1     degree line.  In one case the gradient
%       |         |       vector is more horizontal, and in the other
%       O    X    O       it is more vertical.  There are eight
%       |         |       divisions, but for the non-maximum supression
%    (1)|         |(4)    we are only worried about 4 of them since we
%       O----O----O       use symmetric points about the center pixel.
%        (2)   (3)


[m,n] = size(mag);

% Find the indices of all points whose gradient (specified by the
% vector (ix,iy)) is going in the direction we're looking at.

switch direction
    case 1
        idx = find((iy<=0 & ix>-iy)  | (iy>=0 & ix<-iy));
    case 2
        idx = find((ix>0 & -iy>=ix)  | (ix<0 & -iy<=ix));
    case 3
        idx = find((ix<=0 & ix>iy) | (ix>=0 & ix<iy));
    case 4
        idx = find((iy<0 & ix<=iy) | (iy>0 & ix>=iy));
end

% Exclude the exterior pixels
if ~isempty(idx)
    v = mod(idx,m);
    extIdx = find(v==1 | v==0 | idx<=m | (idx>(n-1)*m));
    idx(extIdx) = [];
end

ixv = ix(idx);
iyv = iy(idx);
gradmag = mag(idx);

% Do the linear interpolations for the interior pixels
switch direction
    case 1
        d = abs(iyv./ixv);
        gradmag1 = mag(idx+m).*(1-d) + mag(idx+m-1).*d;
        gradmag2 = mag(idx-m).*(1-d) + mag(idx-m+1).*d;
    case 2
        d = abs(ixv./iyv);
        gradmag1 = mag(idx-1).*(1-d) + mag(idx+m-1).*d;
        gradmag2 = mag(idx+1).*(1-d) + mag(idx-m+1).*d;
    case 3
        d = abs(ixv./iyv);
        gradmag1 = mag(idx-1).*(1-d) + mag(idx-m-1).*d;
        gradmag2 = mag(idx+1).*(1-d) + mag(idx+m+1).*d;
    case 4
        d = abs(iyv./ixv);
        gradmag1 = mag(idx-m).*(1-d) + mag(idx-m-1).*d;
        gradmag2 = mag(idx+m).*(1-d) + mag(idx+m+1).*d;
end
idxLocalMax = idx(gradmag>=gradmag1 & gradmag>=gradmag2);

