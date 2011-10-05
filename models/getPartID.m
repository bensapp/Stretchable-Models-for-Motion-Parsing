function [id] = getPartID(name)
% convert part name to numeric id

ids.luarm = 1;
ids.ruarm = 2;
ids.torso = 3;
ids.llarm = 4;
ids.rlarm = 5;

if isfield(ids,name)
    id = ids.(name);
else
    id = -1;
end