function x = defvar(varstring,defval)
%sets var to default value if var is empty or does not exist

try 
    x = evalin('caller',varstring);
    if isempty(x)
        x = defval;
    end
catch me
    x = defval;
end
