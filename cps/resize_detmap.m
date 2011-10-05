function d=resize_detmap(d0,dims,varargin)
if isequal(size(d0),dims), d = d0; return; end
dxy = zeros([dims(1:2) size(d0,3)]);


dxy = imresize(d0,dims(1:2),varargin{:});


if size(d0,3) == dims(3), d=dxy; return; end

% scale in the z direction, with rotational interpolation by concatenating
% then truncating
dcat = cat(3,dxy,dxy,dxy);
d = zeros(dims);
for i=1:dims(1)
    t = imresize(squeeze(dcat(i,:,:)),[dims(2) 3*dims(3)],varargin{:});
    t = t(:,dims(3)+1:end-dims(3));
    d(i,:,:) = t;
end
0;