function [id] = getArmPartID(name)
% convert part name to numeric id

ids.luarm = 1;
ids.ruarm = 2;
ids.llarm = 3;
ids.rlarm = 4;
ids.lhand  = 5;
ids.rhand  = 6;

if isfield(ids,name)
    id = ids.(name);
else
    id = -1;
end