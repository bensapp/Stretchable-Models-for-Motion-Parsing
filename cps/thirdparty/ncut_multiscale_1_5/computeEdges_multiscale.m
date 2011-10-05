function [emag,ephase]=computeEdges_multiscale(image,scale);
%TODO:rename to multichannel
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


[p,q,r]=size(image);
emag=zeros(p,q,r);
ephase=zeros(p,q,r);
for i=1:r
    [emag(:,:,i),ephase(:,:,i)]=computeEdges_multiscale_aux(image(:,:,i),scale);
end


function [emag,ephase]=computeEdges_multiscale_aux(image,scale);

[ephase,emag]=computeEdgeFast(image,scale);
%{
filter_par = [4,scale,30,3];  %[9,30,4]
threshold=1e-14;
% [x,y,gx,gy,par,threshold,emag,ephase,g,FIe,FIo,mago] = quadedgep_optimized(image,filter_par,threshold);
[x,y,gx,gy,emag,ephase,g,FIe,FIo,mago] = quadedgep_optimized(image,filter_par,threshold);
%}
% [imageEdges,imageEdges2,mag,angle] = edge2(image,'canny');
0;
