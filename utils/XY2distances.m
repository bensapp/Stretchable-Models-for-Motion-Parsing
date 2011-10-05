function distances = XY2distances(X1,X2,Sigma);
%{
Timothee Cour
TODO:voir mex_XY2distances_trans
%}

 
[n1,k] = size(X1);
[n2,k] = size(X2);
if nargin >= 3
    if ischar(Sigma) && strcmp(Sigma,'Sigma')
        X1 = X1-repmat(mean(X1,1),n1,1);
        X2 = X2-repmat(mean(X2,1),n2,1);
        Sigma = [X1;X2]'*[X1;X2];
    end
    temp = inv(real(sqrtm(Sigma)));
%     temp = inv(Sigma);
%     temp = chol(temp);
    X1 = X1*temp;
    X2 = X2*temp;
end
temp1 = sum(X1.^2,2);
temp2 = sum(X2.^2,2);
distances=(-2*X1)*(X2');
distances=bsxfun(@plus,distances,temp1);
distances=bsxfun(@plus,distances,temp2');

 
%for numerical reasons
distances=max(distances,0);