function dispStack(stack);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if nargin<1
    if verLessThan2('7.1')
        disp('no stack available in this version');
        return;
    end
    temp=lasterror;
    disp(['handled error: ',temp.message]);
    stack=temp.stack;
end
% disp('stack: ');
for i=1:length(stack)
    disp(['In ','<a href="matlab: opentoline(''',stack(i).file,''',',num2str(stack(i).line),');">',stack(i).name,' at ',num2str(stack(i).line),'</a>']);    
end

% com.mathworks.mlservices.MLEditorServices.toString(stack(i).file);
% com.mathworks.mlservices.MLEditorServices.builtinGetNumOpenDocuments()

