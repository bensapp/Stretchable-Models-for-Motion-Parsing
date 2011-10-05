function [armstate_info] = addHandDetFeatures(armstate_info,datadir)
assert(numel(armstate_info)==1);
assert(strcmp(armstate_info.name(2:end), 'hand'));

[~,fstem] = fileparts(armstate_info(1).imgfile);
filepath = sprintf('%s/handdets/%s.mat',datadir,fstem);

skindet = loadvar(filepath,'resp_skin_max');
flowdet = loadvar(filepath,'resp_flow_max');

skindet = (imresize(skindet,armstate_info.dims(1:2),'bilinear'));
flowdet = (imresize(flowdet,armstate_info.dims(1:2),'bilinear'));

rawskinf = skindet(armstate_info.states);
rawflowf = flowdet(armstate_info.states);

armstate_info.unary_features_raw = [armstate_info.unary_features_raw rawskinf rawflowf];

%% binarize
nbins = 10;
flow_bininfo = loadvar('flowhanddet-discretization-info.mat');
skin_bininfo = loadvar('skinhanddet-discretization-info.mat');

bi = flow_bininfo.lhand;
uflow = fastdiscretize(rawflowf,nbins,bi.quantiles(1,2),bi.quantiles(1,end-2));  %imagesc(uflow), colormap gray
bi = skin_bininfo.lhand;
uskin = fastdiscretize(rawskinf,nbins,bi.quantiles(1,2),bi.quantiles(1,end-1));

armstate_info.unary_features = [armstate_info.unary_features uskin uflow];

% tack on feature indices
maxind = maxFeatureInd(armstate_info.featinds);
armstate_info.featinds.handskin = maxind+1:maxind+size(uskin,2);
maxind = maxFeatureInd(armstate_info.featinds);
armstate_info.featinds.handflow = maxind+1:maxind+size(uflow,2);
0;

