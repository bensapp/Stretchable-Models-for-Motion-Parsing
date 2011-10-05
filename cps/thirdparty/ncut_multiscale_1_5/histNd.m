function [H,indH] = histNd(vals,dims,isRescale);
% Timothee Cour
% GRASP Lab, University of Pennsylvania, Philadelphia
% Date: 06-Jul-2006 21:17:15
% DO NOT DISTRIBUTE
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


if nargin<3
    isRescale=1;
end

[n,k]=size(vals);
if isRescale
    vals=vals-repmat(min(vals,[],1),n,1);
    vals=vals./repmat(max(vals,[],1),n,1);
end
dims=dims(:)';

temp=repmat(dims,n,1);
vals=1+round(vals.*temp);
indH=min(temp,max(vals,1));
H=accumarray(indH,1,dims,@sum);

if nargout>=2
    dim=length(dims);
    if dim==2
        indH=sub2ind(dims,indH(:,1),indH(:,2));
    elseif dim==3
        indH=sub2ind(dims,indH(:,1),indH(:,2),indH(:,3));
    else
        error('TODO');
    end
end
