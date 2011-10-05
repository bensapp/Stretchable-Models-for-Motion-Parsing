function box = rotatebox(box0,theta)
% box = rotatebox(box0,theta)
% rotates box around center point by theta (in radians)
% outputs points of four corners in order [tl,tr,br,bl]

n = size(box0,1);
tl = box0(:,1:2)';
br = box0(:,3:4)';
tr = box0(:,[3 2])';
bl = box0(:,[1 4])';

box = zeros(2,4,n);
for k=1:n
    pts = [tl(:,k) tr(:,k) br(:,k) bl(:,k)];
    ptsr = rotatePts(pts,theta,mean(pts,2));
    box(:,:,k) = ptsr;
end

%{

ca
figure
myplot(pts,'b')
hold on
myplot(ptsr,'g')

%}