function filesError = compileDir(dirInput);
% compiles mex files in specified directory
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if nargin<1
    dirInput=pwd;
end
files=dir2(dirInput);
filesError = compileFiles({files.filepath});

