function [X] = initstruct(src, dest)

if isempty(src)
    X = dest;
    return;
end

f = fieldnames(src);
if isempty(f)
    X = dest;
else
    for i = 1:numel(f)
        X.(f{i}) = [];
    end
    X = copystruct(X, dest);
end