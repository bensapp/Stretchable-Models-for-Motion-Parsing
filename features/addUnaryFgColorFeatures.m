function [armstate_infos] = addUnaryFgColorFeatures(armstate_infos,datadir, varargin)

defaults.smoothdims = 3;
opts = propval(varargin, defaults);

frames = [armstate_infos.currframe];
assert(all(frames == mean(frames)))

[~,fstem] = fileparts(armstate_infos(1).imgfile);
filestem = sprintf('%s/cps-features/%s',datadir,fstem);
fginfo = load([filestem '_fg_color_detmaps.mat'],'face_color','torso_color');

face_smooth = scale01(blurimg(fginfo.face_color, opts.smoothdims));
torso_smooth = scale01(blurimg(fginfo.torso_color, opts.smoothdims));

skin_bininfo = loadvar('fgskin-discretization-info.mat');
torso_bininfo = loadvar('fgtorso-discretization-info.mat');


nbins = 10;
for i = 1:numel(armstate_infos)
    assert(all(armstate_infos(i).dims([1 2]) == size2(face_smooth, [1 2])));

    rawf = [face_smooth(armstate_infos(i).states) torso_smooth(armstate_infos(i).states)];
    armstate_infos(i).unary_features_raw = [armstate_infos(i).unary_features_raw rawf];
    
    bi= skin_bininfo.(armstate_infos(i).name);
    u1 = fastdiscretize(rawf(:,1),nbins,bi.minval,bi.maxval);
    
    bi= torso_bininfo.(armstate_infos(i).name);
    u2 = fastdiscretize(rawf(:,2),nbins,bi.minval,bi.maxval);
    
    armstate_infos(i).unary_features = [armstate_infos(i).unary_features u1 u2];
    
    % tack on feature indices
    maxind = maxFeatureInd(armstate_infos(i).featinds);
    armstate_infos(i).featinds.skincolor = maxind+1:maxind+size(u1,2);
    maxind = maxFeatureInd(armstate_infos(i).featinds);
    armstate_infos(i).featinds.torsocolor = maxind+1:maxind+size(u2,2);
    0;
end




