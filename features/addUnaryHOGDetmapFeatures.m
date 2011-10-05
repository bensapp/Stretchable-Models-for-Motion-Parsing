function [armstate_info] = addUnaryHOGDetmapFeatures(armstate_info, datadir, varargin)

assert(numel(armstate_info)==1);

[~,fstem] = fileparts(armstate_info(1).imgfile);
filepath = sprintf('%s/cps-features/%s_hog_detmaps.mat',datadir,fstem);
hoginfo = load(filepath);

hoginfo = flip_larm_rarm_hoginfo(hoginfo);
bininfo = loadvar('hog-discretization-info.mat');

nbins = 10;
idx = strcmp(armstate_info.name,{hoginfo.parts.name});
if ~isempty(idx)
    detmap = max(hoginfo.parts(idx).detmap,[],3);
    
    rawf = detmap(armstate_info.states);
    armstate_info.unary_features_raw = [armstate_info.unary_features_raw rawf];
    
    bi = bininfo.(armstate_info.name);
    u = fastdiscretize(rawf(:),nbins,bi.minval,bi.maxval);
    armstate_info.unary_features = [armstate_info.unary_features u];
    
    % tack on feature indices
    maxind = maxFeatureInd(armstate_info.featinds);
    armstate_info.featinds.hog = maxind+1:maxind+size(u,2);
    0;
end

return

%% debug: play detmap "movie"
partind = 3;
for i=armstate_info.currframe:armstate_info.currframe+50
    tmp = armstate_info;
    tmp.currframe = i;
    filestem = getFeatureFileStem(tmp);
    hoginfo = flip_larm_rarm_hoginfo(load([filestem '_hog_detmaps.mat']));
    detmap = max(scale01(hoginfo.parts(partind).detmap),[],3);
    
    clf, imagesc([detmap]), title(hoginfo.parts(partind).name), drawnow
    
end



