function [classes,EigenvectorsRotated,convergence] = discretisation(Eigenvectors,isRandom);
% algorithm for discretisation of eigenvectors: implementation based on Stella Yu's thesis
% input: Eigenvectors (nxk or pxqxk)
% isRandom: 1 iff non-deterministic
% output:
% classes: discretised eigenvectors
% EigenvectorsRotated: rotation of eigenvectors closest to discretised eigenvectors
% convergence: convergence flag
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


if nargin<2
    isRandom=0;
end
[n,k]=size(Eigenvectors);
isImage = 0;
if size(Eigenvectors,3)>1
    isImage = 1;
    [p,q,k]=size(Eigenvectors);
    n=p*q;
    Eigenvectors=reshape(Eigenvectors,n,k);    
%     error('size(Eigenvectors,3)>1');
end
EigenvectorsRotated = Eigenvectors;
% if k == 1
%     classes = ones(n,1);
%     convergence = 1;
% else
%     [classes,EigenvectorsRotated,convergence]=clusteringBasic(Eigenvectors);
% end

if k == 1
    classes = ones(n,1);
    convergence = 1;
elseif k == 2
    classes = ones(n,1);
    classes(Eigenvectors(:,2) < mean(Eigenvectors(:,2))) = 2;  
	EigenvectorsRotated = Eigenvectors;
    convergence = 1;
else
    [classes,EigenvectorsRotated,convergence]=clusteringBasic(Eigenvectors,isRandom);
end


% classes = ones(n,1);
% if k == 2 %TODO : choisir 1ere ou 2eme solution, ou utiliser clusteringBasic
%     classes(Eigenvectors(:,2) < mean(Eigenvectors(:,2))) = 2;
%     %classes(Eigenvectors(:,2) < (max(Eigenvectors(:,2)) + min(Eigenvectors(:,2)) ) / 2) = 2;
% elseif k > 2
%     [classes,EigenvectorsRotated]=clusteringBasic(Eigenvectors);
% end

if isImage
    classes=reshape(classes,p,q);
    EigenvectorsRotated=reshape(EigenvectorsRotated,p,q,k);
end