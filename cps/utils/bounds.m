function b = bounds(x);
% Timothee Cour, 12-Jun-2008 16:47:55 -- DO NOT DISTRIBUTE

if isempty(x)
    b=[];
    return;
end
if issparse(x)
    b(1)=min(min(x));
    b(2)=max(max(x));
else
    b(1) = min(x(:));
    b(2) = max(x(:));
end
b = full(b);