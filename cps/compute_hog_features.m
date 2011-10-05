function feats = compute_hog_features(opts,state_info)

detmapfile = fullfile(opts.outputdir,[opts.filestem,'_hog_detmaps.mat']);
detmaps = load2(detmapfile);

% unary features
for i=1:length(state_info)
    
    d = detmaps(strcmp(state_info(i).name,{detmaps.name})).detmap;
    d = resize_detmap(d,state_info(i).state_dims);
    feats(i).unary_features = d(state_info(i).states);
    feats(i).name = state_info(i).name;
    
end