function [layers,C]=compute_layers_C_multiscale(p,q);
% compute multiscale image affinity matrix W and multiscale constraint
% matrix C from input image
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


layers = computeParametersLayers(p,q);

[C,C12]=computeMultiscaleConstraints(layers);

% compute each layers(i).location as subsamples of the finest layer
layers=computeLocationFromConstraints(C12,layers);

