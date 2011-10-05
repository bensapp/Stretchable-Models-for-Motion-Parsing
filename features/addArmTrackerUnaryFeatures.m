function [armstate_info] = addArmTrackerUnaryFeatures(armstate_info, varargin)

% all parts get features for skin, torso color

filestem = armtracking_root('eccv_features', ...
    armstate_info.moviename,sprintf('%08d', armstate_info.currframe));

fginfo = load([filestem '_fg_color_detmaps.mat']);



%%

