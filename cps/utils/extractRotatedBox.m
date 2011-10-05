function varargout = extractRotatedBox(box,img,do_mirror)

%demo
%{
mex utils/mex_myimtransform.cpp
box = rotatebox(box_from_dims(60,200,[80;160]),0);
img = imread('~/html/me.jpg');
extractRotatedBox(box,img,true);
%}

if nargin<3, do_mirror = true; end
outerbox = pts2box(box);


[T,theta] = rotbox2transform(box);

box_mapped = T*[box; 1 1 1 1];
box_straight = round(pts2box(box_mapped));

newdims = boxsize(box_straight);
image2 = myimtransform(img,T,0,newdims,do_mirror);
% res = extractWindow(image2,box2rhull(box_straight));
res = image2;

assert(all(res(:) >= 0))
if nargout  == 0
    
    subplot(1,3,1)
    imsc(img,1);
    hold on
    plotboxrot(box)

    subplot(1,3,2)
    imsc(image2,1)
    hold on
    plotboxrot(box_mapped(1:2,:))
    
    subplot(1,3,3)
    imsc(res,1)

else
    varargout{1} = res;
end

function [A,theta]= rotbox2transform(pts)

tl = pts(:,1);
tr = pts(:,2);
bl = pts(:,4);

%map 3 points to their canonical positions (1,1),(w,1),(1,h)
map_from = [tl tr bl];
map_to = [[0;0] [1*norm(tr-tl);0] [0;1*norm(bl-tl)]];
map_to(1,:) = map_to(1,:) +1;
map_to(2,:) = map_to(2,:) +1;

 A = align_2d_points_affine((map_from),(map_to));
 
 theta = atan2(A(2,1),A(1,1));
 A = [A; [0 0 1]];
0;

