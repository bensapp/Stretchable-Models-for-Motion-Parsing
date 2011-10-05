function [W,Dinvsqrt,D]=normalizeW_D(W,Dinvsqrt,isAbs);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

if nargin<2 || isempty(Dinvsqrt)
    if nargin<3
        isAbs=0;
    end
    if isAbs
        D = mex_computeRowSum(abs(W));
    else        
        D = mex_computeRowSum(W);
    end
    Dinvsqrt = 1./sqrt(D+eps);
end

if issparse(W)
    W = spmtimesd(W,Dinvsqrt,Dinvsqrt);
else
    W = W .* (Dinvsqrt*Dinvsqrt');
end

