function Y=reshape2(X,dims);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if prod(dims)==numel(X)
    if length(dims)==1
        dims=[dims,1];
    end
    Y=reshape(X,dims);
else
    dims(end+1)=numel(X)/prod(dims);
    Y=reshape(X,dims);
end