function [src] = copystruct(src, dest)
% [src] = copystruct(src, dest)

f = fieldnames(dest);
for i = 1:numel(f)
    src.(f{i}) = dest.(f{i});
end
    