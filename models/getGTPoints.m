function [pts] = getGTPoints(armstate_info, p)

if nargin==1 
    p = getPartID(armstate_info.name);
end
if p > 0
    pts = armstate_info.person.parts(p).pts(:,1);
else
    p = getPartID([armstate_info.name(1) 'larm']);
    pts = armstate_info.person.parts(p).pts(:,2);
    if any(isnan(pts))
        pts = armstate_info.person.parts(p).pts(:,1);
        warning('annotation for part %s was NaN', armstate_info.name);
    end
end
