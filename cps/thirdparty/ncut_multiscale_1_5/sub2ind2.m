function ind = sub2ind2(pq,x,y);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if nargin<3
    if isempty(x)
        ind=x;
        return;
    end

    y=x(:,2);
    x=x(:,1);
end
ind = x+pq(1)*(y-1);