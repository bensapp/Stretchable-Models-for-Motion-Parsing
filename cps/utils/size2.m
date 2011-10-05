function [varargout] = size2(x,idx)
% function [varargout] = size2(x,idx)
%if one output, returns the size of x, indexed by idx
%if [o1,o2,..,on] = size2(x,idx), behaves in the following way:
%   s = size(x); s = s(idx); [o1,o2,..,on] = deal(s(1),s(2),...,s(n))
s = size(x);
idx = defvar('idx',1:max(length(s),nargout));

extra = max(idx)-length(s);
if extra > 0
    s = [s ones(1,extra)];
end

s = s(idx);

if nargout <= 1
    varargout = {s};
else
    nout = max(nargout,1);
    for i=1:nout,
        varargout{i} = s(i);
    end
end