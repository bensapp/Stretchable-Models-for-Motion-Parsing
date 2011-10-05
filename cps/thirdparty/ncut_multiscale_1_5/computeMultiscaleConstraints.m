function [C,C12]=computeMultiscaleConstraints(layers);
% layers: parameters for each layer
% C: multiscale constraint matrix C
% C12: each C12{i} is the interpolation matrix between 2 consecutive layers
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


C=[];
C12={};
nTot=0;
for i=1:length(layers)
    nTot=nTot+length(layers(i).indexes);
end
for i=1:length(layers)-1
    layer1=layers(i);
    layer2=layers(i+1);
    [Ci,C12i]=computeMultiscaleConstraint_1scale(layer1.p,layer1.q,layer2.p,layer2.q,layer1.indexes,layer2.indexes,nTot);
    C=[C;Ci];
    C12{i}=C12i;
end
