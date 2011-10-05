function dataW = computeParametersW(image);
% sets parameters for computing multiscale image affinity matrix W
% dataW.edgeVariance: edge variance for intervening contour cue
% dataW.sigmaI: intensity variance for intensity cue
% Florence Benezit, Jianbo Shi
[p,q,r]=size(image);

dataW.edgeVariance=0.08; %0.1 %0.08
% dataW.edgeVariance=0.1; %0.1 %0.08
dataW.sigmaI=0.12;%0.12
if r>1,
    dataW.sigmaI = 1.4*dataW.sigmaI;
end

