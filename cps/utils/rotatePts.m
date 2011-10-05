function [rotpts_recentered] = rotatePts(pts,theta,ctr)
% function [rotpts_recentered] = rotatePts(pts,theta,ctr)

c = cos(theta);
s = sin(theta);
R = [c -s; s c;];


%slower
% pts_minus_ctr = bsxfun(@minus,pts,ctr);
% rot_pts = R*pts_minus_ctr;
% rotpts_recentered = bsxfun(@plus,rot_pts,ctr);

%faster
ptsr = R*pts;
t = -R*ctr+ctr;

if sum(t) == 0
    rotpts_recentered = ptsr;
else
    rotpts_recentered = bsxfun(@plus,ptsr,t);
end

