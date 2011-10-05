function [Y,lambda]=computePCA(X,d,isScaled);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

[n,k]=size(X);
n:nbPoints
%}
if nargin<2
    d=[];
end
[V,lambda,X_mean]=computePCA_eigenvectors(X,d);

[n,k]=size(X);

if nargin>3 && isScaled
    V=V*diag(sqrt(lambda));
end
Y=X*V;
temp=-X_mean*V;
temp=temp(ones(n,1),:);
Y=Y+temp;
