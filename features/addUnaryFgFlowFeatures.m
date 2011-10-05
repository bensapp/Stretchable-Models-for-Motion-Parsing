function [armstate_infos] = addUnaryFgFlowFeatures(armstate_infos,datadir, varargin)

defaults.smoothdims = 3;
opts = propval(varargin, defaults);

frames = [armstate_infos.currframe];
assert(all(frames == mean(frames)))

[~,fstem] = fileparts(armstate_infos(1).imgfile);
filepath = sprintf('%s/cps-features/%s_fg_color_detmaps.mat',datadir,fstem);
fginfo = load(filepath,'face_color','torso_color');

filepath = sprintf('%s/flow/%s.mat',datadir,fstem);
flowmag = loadvar(filepath,'fmcropped');
flowmag = imresize(flowmag,armstate_infos(1).dims(1:2),'bilinear');
flow_smooth = blurimg(flowmag, 3);

nbins = 10;
for i = 1:numel(armstate_infos)

    rawf = flow_smooth(armstate_infos(i).states);
    armstate_infos(i).unary_features_raw = [armstate_infos(i).unary_features_raw rawf];
    
    uf = fastdiscretize(rawf,nbins,0,1);
    
    armstate_infos(i).unary_features = [armstate_infos(i).unary_features uf];
    
    % tack on feature indices
    maxind = maxFeatureInd(armstate_infos(i).featinds);
    armstate_infos(i).featinds.flowfg = maxind+1:maxind+size(uf,2);
    0;
end

