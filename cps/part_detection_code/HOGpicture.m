function [impos,imneg] = HOGpicture(w, bs)
if nargin < 2, bs = 20; end
% HOGpicture(w, bs)
% Make picture of positive HOG weights.

% construct a "glyph" for each orientaion
bim1 = zeros(bs, bs);
bim1(:,round(bs/2):round(bs/2)+1) = 1;
bim = zeros([size(bim1) 9]);
bim(:,:,1) = bim1;
for i = 2:9,
  bim(:,:,i) = imrotate(bim1, -(i-1)*20, 'crop');
end

w0 = w;
% make pictures of positive weights bs adding up weighted glyphs
s = size(w);    
w(w < 0) = 0;    
im = zeros(bs*s(1), bs*s(2));
for i = 1:s(1),
  iis = (i-1)*bs+1:i*bs;
  for j = 1:s(2),
    jjs = (j-1)*bs+1:j*bs;       
%     w_slice = w(i,j,:);
%     w_slice = w_slice.*(w_slice >= median(w_slice(1:9)));
%     w(i,j,:) = w_slice;
    for k = 1:9,
      im(iis,jjs) = im(iis,jjs) + bim(:,:,k) * w(i,j,k);
    end
    
    %I added this so that there is no strong white point in the middle of
    %the cell - bensapp
%     im(iis,jjs) = abs(im(iis,jjs) - mean(bim,3));
  end
end
impos = im;

w = w0;
% make pictures of negative weights bs adding up weighted glyphs
s = size(w);    
w(w >= 0) = 0;    
im = zeros(bs*s(1), bs*s(2));
for i = 1:s(1),
  iis = (i-1)*bs+1:i*bs;
  for j = 1:s(2),
    jjs = (j-1)*bs+1:j*bs;          
    for k = 1:9,
      im(iis,jjs) = im(iis,jjs) - bim(:,:,k) * w(i,j,k);
    end
  end
end
imneg = im;