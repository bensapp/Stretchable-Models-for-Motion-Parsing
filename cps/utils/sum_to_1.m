function [X,Z0] = sum_to_1(X,d)
X = double(X);
if isempty(X), return; end

%nan's screw everything up
nanidx = isnan(X);
X(nanidx) = 0;

if nargin == 1
    Z0 = sum(X(:));
    Z = Z0;
    Z(Z==0) = 1;
    X = X/Z;
   
else
%     %this is a bad hack:
%     if size(X,d) == 1, 
%         X = ones(size(X,d-1),1);
%         return
%     end
    Z0 = sum(X,d);
    Z = Z0;
    Z_1 = 1./Z;
    Z_1(isinf(Z_1)) = 1;
    X = bsxfun(@times,X,Z_1);
end


X(nanidx) = nan;
0;
