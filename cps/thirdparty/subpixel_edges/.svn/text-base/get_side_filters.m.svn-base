function [left, right] = get_side_filters(n_scale, n_filter);
% [left, right] = get_side_filters(n_scale, n_filter);

winsz = 4*n_scale+1;
enlong = 1;

FBo = make_filterbank_odd2(n_filter/2,n_scale,winsz,enlong);

left = cat(3, FBo, -FBo);
right = cat(3, FBo, -FBo);
half_sz = (winsz-1)/2;
[x,y] = meshgrid(-half_sz:half_sz, -half_sz:half_sz);

theta = -([1:n_filter]'-0.5)*2*pi/n_filter;
for ii = 1:n_filter
    idx1 = find(x*sin(theta(ii))+y*cos(theta(ii)) >= 0);
    idx2 = find(x*sin(theta(ii))+y*cos(theta(ii)) <= 0);
    left(idx1+winsz*winsz*(ii-1)) = 0;
    right(idx2+winsz*winsz*(ii-1)) = 0;   
end
s = sum(sum(abs(FBo(:,:,1))/2));
left = abs(left) / s;
right = abs(right) / s;


% % Test
% figure;
% for ii = 1:n_filter
%     subplot(4, 4, ii);
%     imagesc(left(:,:,ii));
%     axis image;    
% end
% 
% figure;
% for ii = 1:n_filter
%     subplot(4, 4, ii);
%     imagesc(right(:,:,ii));
%     axis image;    
% end