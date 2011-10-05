function [armstate_infos edgeInfo] = computeStatesAndFeatures(clip, opts,  varargin)
larmlens = [17 32 47 66];
armstate_infos = [];
for t = 1:numel(clip)
    asi = makeInitialStatesFromCPS(clip(t), larmlens, opts.datadir, varargin{:});
    asi = setfield2(asi,'currframe',t);
    armstate_infos = [armstate_infos asi];
end
armstate_infos = addUnaryFeatures(armstate_infos,opts.datadir);
edgeInfo = precomputeEdgeInfo(armstate_infos,opts.datadir);   

