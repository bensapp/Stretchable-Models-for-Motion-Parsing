function [imconts im_nrm_x im_nrm_y] = ptsnrm_pts2map(img,pts, nrm)

[sx sy ch] = size(img);
imconts = zeros(sx, sy);
ind_p = sub2ind([sx sy], pts(:,2), pts(:,1));
imconts(ind_p) = 1;

im_nrm_x = zeros(sx, sy);
im_nrm_x(ind_p) = nrm(:,1);
im_nrm_y = zeros(sx, sy);
im_nrm_y(ind_p) = nrm(:,2);