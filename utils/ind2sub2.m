function [x,y] = ind2sub2(pq,ind);
% Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE


[x,y]=mex_ind2sub(pq,ind);
%{
% ind=double(ind);
assert(isa(ind,'double'));
y = floor((ind-1)/pq(1))+1;
x = round(ind-pq(1)*(y-1));
% x = ind-pq(1)*(y-1);

%}

if nargout==1
    x=[x(:),y(:)];
end
