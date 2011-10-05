function path2=changeExt(path1,ext2);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if ~strcmp(ext2(1),'.')
    error('ext2 must start with .');
end
[path,name,ext]=fileparts(path1);
path2=fullfile(path,[name,ext2]);

