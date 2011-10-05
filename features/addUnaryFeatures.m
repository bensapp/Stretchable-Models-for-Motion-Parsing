function [armstate_infos] = addUnaryFeatures(armstate_infos,datadir)

armstate_infos = setfield2(armstate_infos,'featinds',[]);
%%
% add all fg color features
frames = [armstate_infos.currframe];
[framerange, frameidx, tidx] = unique(frames);

fprintf('fg color...\n');
for t = 1:numel(framerange)
    idx = find(tidx==t);
    armstate_infos(idx) = addUnaryFgColorFeatures(armstate_infos(idx),datadir);
    armstate_infos(idx) = addUnaryFgFlowFeatures(armstate_infos(idx),datadir);
end
%%
% if necessary, add hog detmap features
fprintf('hog detmap/location...\n'); 
for i = 1:numel(armstate_infos)

    if ~strcmp(armstate_infos(i).name(2:end), 'hand')
        armstate_infos(i) = addUnaryHOGDetmapFeatures(armstate_infos(i),datadir);
    end
    
    armstate_infos(i) = addUnaryLocationFeatures(armstate_infos(i));
end

%% hand dets
fprintf('hand dets...\n'); 
for i = 1:numel(armstate_infos)
    if strcmp(armstate_infos(i).name(2:end), 'hand')
        armstate_infos(i) = addUnaryHandDetFeatures(armstate_infos(i),datadir);
    end
end


