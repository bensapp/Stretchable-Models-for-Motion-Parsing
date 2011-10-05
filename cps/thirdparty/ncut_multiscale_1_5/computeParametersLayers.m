function layers=computeParametersLayers(p,q);
% sets parameters for each layer in the multiscale grid
% p,q: input image size
% output: each layers(i) is a struct with fields:
% p,q: size of layer
% indexes: indexes of current layer into a global index reference for all
% layers
% weight: weight of layer in multiscale image affinity W
% scales: scale for edge detection used in intervening contour cue
% radius: connection radius of layer (in finest grid)
% mode2: method to compute affinity matrix for current layer
%
% other intermediate variables:
% ns=#layers
% dist=spacing bw grid points in 2 consecutive layers (corresponds to
% subsample factor)
% Florence Benezit, Timothee Cour, Jianbo Shi

max_image_size = max(p,q);

if (max_image_size>120) & (max_image_size<=500),
    ns=3;
    dist=3;
    weight=[2000,4000,10000];%[3000,4000,10000]
    scales=[1,2,4];%[1,2,3];
    radius=[2,3,7];%[2,3,7];
    layers=computeLayers_aux(p,q,ns,dist,weight,scales,radius);
elseif (max_image_size >500),
    % use 4 levels,
    ns=4;
    dist=3;
    weight=[3000,4000,10000,20000];
    scales=[1,2,3,3];
    radius=[2,3,4,6];
    layers=computeLayers_aux(p,q,ns,dist,weight,scales,radius);
% elseif (1),
elseif (max_image_size <=120)
    ns=2;
    dist=3;
    weight=[3000,10000];
    scales=[1,2];
    radius=[2,6];
    layers=computeLayers_aux(p,q,ns,dist,weight,scales,radius);

    %     ns=1;
    %     dist=3;
    %     weight=[3000];
    %     scales=[1];
    %     radius=[6];
    %     layers=computeLayers_aux(p,q,ns,dist,weight,scales,radius);

end

function layers=computeLayers_aux(p,q,ns,dist,weight,scales,radius);
pi=p;
qi=q;
nTot=0;
for i=1:ns
    layers(i).p=pi;
    layers(i).q=qi;
    layers(i).indexes=nTot+(1:pi*qi)';
    nTot=nTot+pi*qi;
    %     layers(i).dist=dist;
    layers(i).weight=weight(i);
    layers(i).scales=scales(i);
    layers(i).radius=radius(i);
    pi=ceil(pi/dist);
    qi=ceil(qi/dist);

    layers(i).mode2='mixed';
    % 'hist' mode may not be available
    % layers(i).mode2='F';
    % layers(i).mode2='IC';
    % layers(i).mode2='hist';
end
