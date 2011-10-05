function [H,map,imagep]=computeFeatureHistogram(image,nbins,dim);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if nargin<3
    dim=2;
end

[p,q,r]=size(image);
n=p*q;
F=reshape(image,n,r);

[Fp,lambda]=computePCA(F);
dims=sqrt(lambda);
dims=dims/max(dims)*nbins;
dims=round(dims);
dims=max(dims,1);
dims=dims(1:dim);
Fp=Fp(:,1:dim);
[H,indH] = histNd(Fp,dims);

map=reshape(indH,p,q);
imagep=reshape(Fp,p,q,size(Fp,2));

