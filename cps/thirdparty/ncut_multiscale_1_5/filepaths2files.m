function files=filepaths2files(filepaths);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if ischar(filepaths)
    filepaths={filepaths};
end

% files=emptyStruct({'name','date','bytes','isdir','path','name0','ext','filepath','stringNumber','number','stringNumber2','number2'});
files=emptyStruct({'name','name0','path','ext','filepath'});
for i=1:length(filepaths)
    filepath=filepaths{i};
    [path,name0,ext]=fileparts(filepath);
    name=[name0,ext];
    files(i).name=name;
    files(i).name0=name0;
    files(i).path=path;
    files(i).ext=ext;
    files(i).filepath=filepath;
end


