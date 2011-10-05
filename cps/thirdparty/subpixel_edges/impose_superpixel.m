function [x2, y2, gx2, gy2] = impose_superpixel(x, y, gx, gy, para);
% [x2, y2, gx2, gy2] = impose_superpixel(x, y, gx, gy, para);

if (~isfield(para, 'superpixel') || isempty(para.superpixel))
    x2 = x;
    y2 = y;
    gx2 = gx;
    gy2 = gy;
    return;
end

if (min(para.superpixel(:)) > 0)
    % Get boundary
    se = strel('square', 3);
    bw1 = imerode(para.superpixel, se);
    bw2 = imdilate(para.superpixel, se);
    para.superpixel = (para.superpixel ~= bw1) | (para.superpixel ~= bw2);
end

img_h = size(para.superpixel, 1);
idx = find(para.superpixel(y(:,1)+(x(:,1)-1)*img_h) > 0);
x2 = x(idx, :);
y2 = y(idx, :);
gx2 = gx(idx);
gy2 = gy(idx);

% % Test 
% figure;
% subplot_tim(1,2,1,1);
% disp_fragments(x,y,gx,gy);
% title('Original');
% subplot_tim(1,2,1,2);
% disp_fragments(x2,y2,gx2,gy2);
% title('Pruned');
