function [oracle] = computeOracleTable(clips, larmlens, opts, varargin)

oracle = [];
for i = 1:numel(clips)
    clip = clips(i);
    timeleft;
    for j = 1:numel(clip.examples)
        timeleft(numel(clip.examples));
    
        %armstate_infos = makeInitialStatesFromECCV(clip.examples(j), larmlens, ...
        %    varargin{:});
        armstate_infos = loadClipStatesEdges(clip, opts);
        
        %armstate_infos = arrayfun(@addGTStates, armstate_infos, repmat(false, size(armstate_infos)));
        oracle = [oracle arrayfun(@computeOracleStateError, armstate_infos)];
%         
%         armstate_infos = arrayfun(@addGTStates, armstate_infos);
%         armstate_infos = addUnaryFgColorFeatures(armstate_infos);
%         armstate_infos = arrayfun(@addUnaryHOGDetmapFeatures, armstate_infos);
%         
%         armstates(trainidx(i)).examples(j).armstate_infos = armstate_infos;
    end
    oj_disp(oj_groupmeans(oracle,{'name'},{'err','nstates'}))
end
    
return;

%%

clear all;
load(armtracking_root('clips_torso-cropped.mat'));
lengths = computeLowerArmLengths(clips(1:8));

clips = breakdownClips(clips, 30, 2);

trainidx = 1:26;
testidx = 27:numel(clips)
lengths = computeLowerArmLengths(clips(trainidx));

opts.larmlens = quantile(lengths, [0.05 0.25 0.5 0.75]);
opts.state_dir = armtracking_root('output-step2-armstate_infos-fixed');
opts.edge_dir = armtracking_root('output-step2-edgeInfo-fixed');

%%

armstate_infos = loadClipStatesEdges(clips(testidx(1)), opts);

%%
ai = addGTStates(armstate_infos, true);
%%
plotPartStates(armstate_infos, 1, 5:6)

%%
j = 1;
 armstate_infos = makeInitialStatesFromECCV(clips(testidx(1)).examples(j), opts.larmlens);

%%
oracle = computeOracleTable(clips(testidx), opts.larmlens, opts);


