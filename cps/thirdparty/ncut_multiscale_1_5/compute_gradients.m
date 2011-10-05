function [IGx,IGy,IGxx,IGyy]=compute_gradients(I,sigma);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

[IGx,IGy,IGxx,IGyy]=compute_gradients(I,sigma);
[IGx,IGy]=compute_gradients(I,sigma);
%}

[p,q,r]=size(I);
assert(r==1);

if nargin>=2
    I=computeSmoothedI(I,sigma);
end


IGx = [diff(I,1,1);zeros(1,q)];
IGy = [diff(I,1,2),zeros(p,1)];
if nargout>=3
    IGxx = [diff(IGx,1,1);zeros(1,q)];
    IGyy = [diff(IGy,1,2),zeros(p,1)];
end

