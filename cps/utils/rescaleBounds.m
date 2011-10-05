function [z2,a,b]=rescaleBounds(z1,bounds1,bounds2);
% Timothee Cour, 28-Jul-2008 15:19:29 -- DO NOT DISTRIBUTE

z1=double(z1);
if nargin<2 || isempty(bounds1)
    bounds1=bounds(z1);
end
if nargin<3 || isempty(bounds2)
    bounds2=[0,1];
end
x1=bounds1(1);
y1=bounds1(2);
x2=bounds2(1);
y2=bounds2(2);
a=(y2-x2)/(y1-x1);
b=y2-a*y1;

z2=a*z1+b;
z2=max(z2,x2);
z2=min(z2,y2);

