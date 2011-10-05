function box = box_from_dims(w,h,ctr)
% function box = box_from_dims(boxdims,ctr)
% supports multiple boxes at once, all with the same dims, 1 ctr per column
ctr = ctr';
if max(w,h) > 10
    offset = 1;
else 
    offset = 0;
end
left = (ctr(:,1)-w/2);
right = (ctr(:,1)+w/2-offset);
top = (ctr(:,2) - h/2);
bottom = (ctr(:,2) + h/2-offset);
box = [left top right bottom];
