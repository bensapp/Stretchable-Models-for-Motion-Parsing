function myquiver(loc,dir,varargin)
% function myquiver(loc,dir,varargin)

if nargin == 1 || isempty(dir)
    dir = loc;
    loc = zeros(size(dir));
end

if isempty(varargin) || ~any(strcmpi(varargin,'maxheadsize'))
    varargin{end+1} = 'maxheadsize';
    varargin{end+1} = 0.5;
end

if isempty(varargin) || ~any(strcmpi(varargin,'linewidth'))
    varargin{end+1} = 'linewidth';
    varargin{end+1} = 2;
end

if size(loc,1) == 3
    quiver3(loc(1,:),loc(2,:),loc(3,:),dir(1,:),dir(2,:),dir(3,:),0,varargin{:});
elseif size(loc,1) == 2
    quiver(loc(1,:),loc(2,:),dir(1,:),dir(2,:),0,varargin{:});
else
    warning('invalid inputs to myquiver!!!');
end