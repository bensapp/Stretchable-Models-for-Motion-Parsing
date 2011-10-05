function path = getPaths(name)
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

TODO: hide definePaths
%}
% global data;
% path =  getfield(data.paths,name);


path='';
persistent data2;
if isempty(data2) || nargin<1 %allows to clear
    [data2.paths,data2.user,data2.host] = definePaths();
end
if nargin>=1
    path =  data2.paths.(name);
end

    
% if 1%isempty(data) || ~isfield(data,'paths')
%     persistent data2;
%     if isempty(data2) || nargin<1 %allows to clear
%         [data2.paths,data2.user,data2.host] = definePaths();
%     end
%     if nargin>=1
%         path =  data2.paths.(name);
%     end
% else
%     path =  data.paths.(name);
% end

