function X=shiftmat(X0,shifts,val)
% function X=shiftmat(X,shifts,val)
%like padarray, shifts contents of the matrix by padding and cropping
% shifts = [num_rows_shift num_cols_shift]
%only works in 2d arrays for now

if nargin < 3,
    val = 0;
end

if 0
    
    shifty = round(shifts(1));
    shiftx = round(shifts(2));
    w = size(X0,2);
    h = size(X0,1);
    pady = val*ones(abs(shifty),w);
    padx = val*ones(h,abs(shiftx));
    X = X0;
    if shifty > 0
        X = [pady; X(1:h-shifty,:)];
    elseif shifty < 0
        X = [X(abs(shifty)+1:h,:); pady];
    end
    
    if shiftx > 0
        X = [padx X(:,1:w-shiftx)];
    elseif shiftx < 0
        X = [X(:,abs(shiftx)+1:w) padx];
    end
else
    T = eye(3);
    T(1,3) = shifts(2);
    T(2,3) = shifts(1);
    
    X = myimtransform(X0,T,val);
    
%     X = imtransform2(X,T,0,val);
end
return



% padding = round(padding);
%
% for dim=1:length(padding)
%
%     padsize = zeros(ndims(X),1);
%     padsize(dim) = abs(padding(dim));
%
%     if padding(dim) > 0
%         X = padarray(X,padsize,val,'pre');
%
%         [X,perm,nshifts] = shiftdata(X,dim);
%         X = X(1:end-abs(padding(dim)),:);
%         X = unshiftdata(X,perm,nshifts);
%     else
%         X = padarray(X,padsize,val,'post');
%
%         [X,perm,nshifts] = shiftdata(X,dim);
%         X = X(abs(padding(dim))+1:end,:);
%         X = unshiftdata(X,perm,nshifts);
%     end
%
% end