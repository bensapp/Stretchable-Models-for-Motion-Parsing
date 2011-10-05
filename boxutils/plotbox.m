function varargout = plotbox(b,varargin)
% function varargout = plotbox(b,varargin)
nbox = size(b,1);

hs = [];
for i=1:nbox
    c = boxcenter(b);
    h = plot([b(i,1) b(i,3) b(i,3) b(i,1) b(i,1)],[b(i,2) b(i,2) b(i,4) b(i,4) b(i,2)],varargin{:});
    hs = [hs; h];
    hold on
    plot(c(1),c(2),[varargin{1},'x'])
end


if nargout == 1
    varargout{:} = hs;
end