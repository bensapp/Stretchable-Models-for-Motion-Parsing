function newfiles = dir3(str,excludestr)
if ~exist('excludestr','var'), excludestr = []; end
if isdir(str) && str(end) ~= '/'
   str(end+1) = '/'; 
end
t = findstr(str,'/');
path = str;
if ~isempty(t)
    path = str(1:t(end));
end

files = dir(str);
newfiles = [];
k = 1;
for i=1:length(files)
    if findstr(excludestr,files(i).name), continue, end
    if any(strcmp({'.','..'},files(i).name)), continue, end
    newfiles(k).filepath = [path files(i).name];
    newfiles(k).path = path;
    newfiles(k).name = files(i).name;
    newfiles(k).isdir = files(i).isdir;
    newfiles(k).date = files(i).date;
    newfiles(k).bytes= files(i).bytes;
    newfiles(k).datenum= files(i).datenum;
    k = k+1;
end
if isempty(newfiles), 
    return;
end
%sort by filename
[ignore,order] = sort({newfiles.filepath});
newfiles = newfiles(order);

newfiles = newfiles(:);