function [children] = getCanonicalChildren(partid)

% luarm --> ruarm 
%       --> llarm
%  ruarm --> rlarm
%  rlarm --> rhand
% llarm --> lhand

%if partid == getArmPartID('luarm')
%    children = [getArmPartID('ruarm') getArmPartID('llarm')];
%if partid == getArmPartID('ruarm')
%    children = getArmPartID('rlarm');
if partid == getArmPartID('llarm')
    children = [getArmPartID('lhand') getArmPartID('luarm') getArmPartID('rlarm')];
elseif partid == getArmPartID('rlarm')
    children = [getArmPartID('rhand') getArmPartID('ruarm')];
else
    children = [];
end
    
% if partid == getArmPartID('luarm')
%     children = [getArmPartID('ruarm') getArmPartID('llarm')];
% elseif partid == getArmPartID('ruarm')
%     children = getArmPartID('rlarm');
% elseif partid == getArmPartID('rlarm')
%     children = getArmPartID('rhand');
% elseif partid == getArmPartID('llarm')
%     children = getArmPartID('lhand');
% else
%     children = [];
% end