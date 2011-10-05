function image = rgb2lab_2(image);
% Timothee Cour, 28-Jul-2008 15:19:29 -- DO NOT DISTRIBUTE


persistent tag;
if isempty(tag)
    tag=compute_tag();
end
image=mex_rgb2val_tagKernel(image,tag);
image=double(image);%TODO:voir

function tag=compute_tag();
temp=[0:4:255];
[R,G,B]=ndgrid(temp,temp,temp);
R=R(:);
G=G(:);
B=B(:);
colors=[R,G,B];
colors=colors/255;

n=size(colors,1);
colors=reshape(colors,n,1,3);
tag=rgb2lab(colors);
tag=squeeze(tag);
tag=single(tag);
for i=1:3
    tag(:,i)=rescaleBounds(tag(:,i),bounds(tag(:,i)),[0,1]);
end
