function [R,d] = myDirectEvalSegms(S1, S2, pars)

% Compare segments S1 to S2.
%
% -> S(:,six) = [x1 y1 x2 y2]'
%
% if pars.crit == 'col'
% Two segments are equivalent if
% within the thresholds in pars.max_*
%
% if pars.crit == 'endpts'
% Two segmentas are equivalent if
% their endpts are within pars.max_{parall,perp}_dist
%
% Output:
% - R(six) = true iff S1(:,six) equivalent to S2(:,six)
%

S1_col = XY2COL(S1);   
S2_col = XY2COL(S2);

Np = size(S2,2);

%norm factor for classification
norm_fact = S2_col(4,:);

for p = 1:Np
  %
  % current segment1 and segment2
  cs1 = S1(:,p);
  cs2 = S2(:,p);
  %
  % match endpts so that order is same in cs1 and cs2
  temp = vgg_nearest_neighbour_dist(cs1(1:2), reshape(cs2,2,2));
  [trash flip] = min(temp);
  if flip == 2
    cs1 = cs1([3 4 1 2]);
  end
  %
  % distances
  dxy = cs1 - cs2;
  ndxy = zeros(4,1);
  % rotate onto cs2 direction
  theta = -S2_col(3,p);                          % must rotate back
  Rot = [cos(theta) -sin(theta); sin(theta) cos(theta)];
  ndxy(1:2) = Rot * dxy(1:2);                    % now dx -> distance parallel to S2 dir, and dy -> dist perpendicular to it
  ndxy(3:4) = Rot * dxy(3:4);      
  %
  % normalize
  ndxy = ndxy / norm_fact(p);
  %
  % classify
  ndxy = abs(ndxy);
  avg_ndxy = [mean(ndxy([1 3])) mean(ndxy([2 4]))];
  R(p) = (avg_ndxy(1) < pars.max_parall_dist) && (avg_ndxy(2) < pars.max_perp_dist);
  d(p) = max(avg_ndxy);
  %if p == 4
  %    keyboard;
  %end
end




function Scol = XY2COL(S)

% converts segments S(:,ix) = [x1 y1 x2 y2]'
% to Scol(:,ix) = [ctr_x ctr_y orient length]'
%
% with orient in [0,pi]
%

ctrs = [mean(S([1 3], :)); mean(S([2 4], :))];
dx = S(3,:)-S(1,:);
dy = S(4,:)-S(2,:);
lens = sqrt(dx.^2+dy.^2);
orients = atan(dy./dx);  % in [-pi/2,pi/2]
neg = orients < 0;
orients(neg) = orients(neg) + pi;

Scol = [ctrs; orients; lens];
