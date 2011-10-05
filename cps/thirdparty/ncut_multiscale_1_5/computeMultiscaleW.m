function W = computeMultiscaleW (image,layers,dataW,options);
% compute multiscale image affinity matrix W from input image, layer
% parameters layers, and affinity matrix parameters dataW
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


ns=length(layers);
%compute each scale of multiscale W
for i=1:ns
    optionsi=options;
    if isfield(options,'edges')
        optionsi.edges=options.edges(i);
    end        
    Ws{i}=computeW_1scale(image,layers(i),dataW,optionsi);
end
[p,q,r]=size(image);

%hack: for stability, prevents isolated nodes
maxi=max(max(Ws{1}));
Ws{1}=Ws{1}+0.01*maxi*mex_neighborW(p,q,4);

%aggregate each scale of W
W=Ws{1};
Ws{1}=[];
for i=2:ns
    [ni,nj]=size(W);
    [ni2,nj2]=size(Ws{i});
    W=[W,sparse(ni,nj2);sparse(ni2,nj),Ws{i}];
    Ws{i}=[];
end

