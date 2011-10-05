function [S,X_mean]=computeCovariance(X);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

n:nbPoints
%}

[n,k]=size(X);

% S=X'*X;% %memory issue when n large
maxSize=100000;
S=mat_op_bloc('A''A',maxSize,X);
S=S/n;
X_mean=sum(X,1)/n;
S=S-X_mean'*X_mean;
