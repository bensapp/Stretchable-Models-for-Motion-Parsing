function [errorCode,message]=mex_aux(filename,varargin);
% in case there is an #include file.cpp, put shared in the search
% path relative to location of mex file
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE



%if doesnt find certain functions, make sure includeDir is correct

if exist('definePaths','file')==2
    isInclude=1;
    includeDir=getPaths('includeDir');
else
    isInclude=0;
    includeDir=pwd;
end

if nargout == 0
    isVerbose = 1;
else
    isVerbose = 0;
end

% % verbose:
% [errorCode,message]=mex_silent(isVerbose,'-v',['-I',includeDir],filename);%to display warnings 
% disp(message);
% return;

k=0;

k=k+1;args{k}=isVerbose;
k=k+1;args{k}='-O';


args=[args,varargin];
k=k+length(varargin);
% if ~isempty(option2)
%     k=k+1;args{k}=option2;
% end
if isInclude
    k=k+1;args{k}=['-I',includeDir];
end
k=k+1;args{k}=filename;
% if ~isempty(option)
%     k=k+1;args{k}=option;
% end
if ispc
    k=k+1;args{k}='-argcheck';%BUG otherwise?
end


% is_no_mwSize=verLessThan2('7.3');%TODO: use feature inside .cpp (cf email)
% % is_no_mwSize=verLessThan2('7.5');
% if is_no_mwSize
%     k=k+1;args{k}='-DIS_NO_MWSIZE';
% end

if 1%TODO:voir
    k=k+1;args{k}='-largeArrayDims';
end

if ismac
    %% prevents crashing matlab when some symbols are not def'd; overrides option -undefined suppress
    k=k+1;args{k}='LDFLAGS=-bundle -Wl,-flat_namespace -undefined error -Wl,-exported_symbols_list,$MATLAB/extern/lib/maci/mexFunction.map';    
end

%% to export for matlab <7.1, use those 2 lines
% if ispc
%     k=k+1;args{k}=['-output'];
%     k=k+1;args{k}=changeExt(filename,'.dll');
% end

% weird: seems to be needed to avoid linking errors
% disp(args);
% if ~(ispc || ismac)
% %     drawnow();
%     disp(args);
% end

[errorCode,message]=mex_silent(args{:});
0;
%{
if isempty(option) && isempty(option2)
    [errorCode,message]=mex_silent(isVerbose,'-O',['-I',includeDir],filename);
elseif ~isempty(option) && isempty(option2)
    [errorCode,message]=mex_silent(isVerbose,'-O',['-I',includeDir],filename,option);
elseif isempty(option) && ~isempty(option2)
    [errorCode,message]=mex_silent(isVerbose,'-O',option2,['-I',includeDir],filename);
elseif ~isempty(option) && ~isempty(option2)
    [errorCode,message]=mex_silent(isVerbose,'-O',option2,['-I',includeDir],filename,option);
end
%}

% mex('-O',filename);
% mex(filename);


% if isempty(option) && isempty(option2)
%     mex('-O',['-I',includeDir],filename);
% elseif ~isempty(option) && isempty(option2)
%     mex('-O',['-I',includeDir],filename,option);
% elseif isempty(option) && ~isempty(option2)
%     mex('-O',option2,['-I',includeDir],filename);
% elseif ~isempty(option) && ~isempty(option2)
%     mex('-O',option2,['-I',includeDir],filename,option);
% end
