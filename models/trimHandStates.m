
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


