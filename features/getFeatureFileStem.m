function [filestem] = getFeatureFileStem(armstate_info,datadir)

filestem = sprintf('%s/cps-features/%08d',datadir,armstate_info.currframe);

% filestem = armtracking_root('eccv_features', ...
%     armstate_info.moviename,sprintf('%08d', armstate_info.currframe));
