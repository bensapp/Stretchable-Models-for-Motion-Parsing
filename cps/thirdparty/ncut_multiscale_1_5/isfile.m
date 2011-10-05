function isValid=isfile(filepath);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

isValid=false;
if isempty(filepath)
    return;
end

temp=dir(filepath);
if length(temp)~=1
    return;
end
[path,name,ext]=fileparts(filepath);
filepath2=fullfile(path,temp.name);
isValid=isequal(filepath2,filepath);

