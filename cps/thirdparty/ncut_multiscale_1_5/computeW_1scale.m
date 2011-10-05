function W=computeW_1scale(image,layer,dataW,options);
% compute 1 scale of multiscale image affinity matrix W
% input:
% image: pxq or pxqxk (for example, RGB image)
% layer: parameters for current layer
% dataW: parameters for affinity matrix W
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE



if isfield(layer,'mode2') && ~isempty(layer.mode2)
    if strcmp(layer.mode2,'hist')
        [wi,wj] = cimgnbmap_lower([layer.p,layer.q],layer.radius,1);
        W=computeW_multiscale_hist(layer,image,wi,wj);
        W = W*layer.weight;

        return;
    end
end


% for each layer in image, compute corresponding partial affinity matrix
[p,q,r]=size(image);
for j=1:r,
    optionsj=options;
    if isfield(options,'edges')
        optionsj.edges.emag=options.edges.emag(:,:,j);
        optionsj.edges.ephase=options.edges.ephase(:,:,j);
    end
    
    Wj = computeW_1scale_1channel (image(:,:,j),layer,dataW,optionsj);
    if j==1
        W=Wj;
    else
        W = min(W,Wj);
    end
end



function W=computeW_multiscale_hist(layer,image,wi,wj);
nbins=200;
sigmaHist=2;

[p,q,r]=size(image);
n=p*q;
[H,map,Fp]=computeFeatureHistogram(image,nbins,2);
Fp=reshape2(Fp,n);
mex_normalizeColumns(Fp);
Fp=Fp.*repmat(1./std(Fp),n,1);
Fp=Fp*sigmaHist;

options.mode='multiscale_hist';
options.F=Fp;
options.hist=-H;
options.map=map;
options.ephase=[];
options.isPhase=0;
options.location=layer.location;
W = mex_affinity_option(wi,wj,options);

