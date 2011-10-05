function [ephase,emag]=computeEdgeFast(I,sigma);
%TODO:optimize
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


if nargin<2
    sigma=2;
end

[IGx,IGy,IGxx,IGyy]=compute_gradients(I,sigma);


ephase=IGxx+IGyy;
ephase=(ephase>0)-(ephase<0);

if nargout>=2
    % emag=sqrt(IGx.^2+IGy.^2);
    emag=sqrt(IGx.^2+IGy.^2+IGxx.^2+IGyy.^2);
%     emag=sqrt(IGx.*IGx+IGy.*IGy+IGxx.*IGxx+IGyy.*IGyy);
end

