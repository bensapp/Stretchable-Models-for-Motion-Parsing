function [x2, y2, img_h, img_w, x_off, y_off] = pad_edgelets(x, y, border);

if (nargin < 3)
    border = 5;
end
if (border == -1)
    % No border, original positions
    x2 = x;
    y2 = y;
    img_w = max(x(:, 1));
    img_h = max(y(:, 1));
    x_off = 0;
    y_off = 0;
    return;
end

min_x1 = min(x(:,1));
min_y1 = min(y(:,1));
img_h = round(max(y(:,1))-min_y1)+1+border*2;
img_w = round(max(x(:,1))-min_x1)+1+border*2;
x2(:,1) = round(x(:,1)-min_x1)+1+border;
y2(:,1) = round(y(:,1)-min_y1)+1+border;
x2(:,2) = x(:,2)-min_x1+1+border;
y2(:,2) = y(:,2)-min_y1+1+border;
x_off = -min_x1+1+border;
y_off = -min_y1+1+border;
