function mkdir2(path);
[path2,name,ext] = fileparts(path);
if isempty(ext)
    system(['mkdir -p ',path]);
else
    system(['mkdir -p ',path2]);
end
% if exist(path)~=7
%     mkdir(path);
% end

