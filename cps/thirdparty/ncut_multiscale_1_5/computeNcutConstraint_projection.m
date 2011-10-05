function [X,lambda,timing,constraintViolation] = computeNcutConstraint_projection(W,U,nbEigenvectors,isncut);
% X = Max Ncut(W)
% s.t. constraint : U*X = 0
% similar syntax to computeKFirstEigenvectors
% based on Stella Yu's Grouping with bias, with a more efficient
% numerical implementation to compute subspace projection (avoids inversing a full matrix)
%
% TODO : support full W in mex_projection_QR_symmetric 
% TODO : try with U directly instead of R
% TODO : constraintViolation = ...
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


constraintViolation=[];

if nargin < 4
    isncut = 1;
end

[k,n] = size(U);

% stability factor
offsetFactor = 0.002;%0; 100;

if isncut
%     D = mex_computeRowSum(W);
    D = mex_computeRowSum(abs(W));
    offset = offsetFactor * mean(D);
    if offset ~= 0        
        D = D + 2*offset;
        W = W + spdiags(offset*ones(n,1),0,n,n);
    end
    
    Dinvsqrt = 1./sqrt(D+eps);
    if issparse(U)
        U = spmtimesd(U,[],Dinvsqrt);
        C=U*U';
        try
            R = cholinc(C,'0');
        catch
            %R = cholinc(C,0.01);
            R = cholinc(C,1e-6);
        end
    else
        U = U * diag(Dinvsqrt);
        C=U*U';
        R = chol(C);
    end
else
    if issparse(U)
        C=U*U';
        %         R = cholinc(C,'0');
        R = cholinc(C,1e-6);
    else
        C=U*U';
        R = chol(C);
    end
end

options = getDefaultOptionsEigs(n,nbEigenvectors);
if isncut
  if(1)
    if issparse(W)
        W = spmtimesd(W,Dinvsqrt,Dinvsqrt);
        %voir tril(W)
        [result,timing] = eigs_optimized(@mex_projection_QR_symmetric,[],nbEigenvectors,options,tril(W),U',R);
    else
        W = W .* (Dinvsqrt*Dinvsqrt');
        temp = eye(n)-U'*inv(R'*R)*U;
        W = temp * W * temp;
        W = (W + W')*0.5;
        [result,timing] = eigs_optimized(W,[],nbEigenvectors,options);
    end
    X = spdiags(Dinvsqrt,0,n,n) * result.X;
  end

  if(0)
  mex_projection_QR_symmetric(tril(W), U', R);
  W = spmtimesd(W,Dinvsqrt,Dinvsqrt);
  % W = W .* (Dinvsqrt*Dinvsqrt');
  temp = speye(n)-U'*inv(R'*R)*U;
  W = temp * W * temp;
  W = (W + W')*0.5;
  [X lambda] = eigs(W,nbEigenvectors,'LA', options);
  lambda = diag(lambda);
  [val,indexesOrdered] = sort(lambda,'descend');
  lambda = lambda(indexesOrdered);
  X = X(:, indexesOrdered);
  X = spdiags(Dinvsqrt,0,n,n) * X;
  end
else
  if(1)
    if issparse(W)
        [result,timing] = eigs_optimized(@mex_projection_QR_symmetric,[],nbEigenvectors,options,tril(W),U',R);
    else
        temp = eye(n)-U'*inv(R'*R)*U;
        W = temp * W * temp;
        W = (W + W')*0.5;
        [result,timing] = eigs_optimized(W,[],nbEigenvectors,options);
    end
    X = result.X;
  end
  
  if(0)
  temp = eye(n)-U'*inv(R'*R)*U;
  W = temp * W * temp;
  W = (W + W')*0.5;
  [X lambda] = eigs(W,nbEigenvectors,'LA', options);
  lambda = diag(lambda);
  [val,indexesOrdered] = sort(lambda,'descend');
  lambda = lambda(indexesOrdered);
  X = X(:, indexesOrdered);
  end

end
lambda = result.lambda;
% timing = [];
mex_normalizeColumns(X);
