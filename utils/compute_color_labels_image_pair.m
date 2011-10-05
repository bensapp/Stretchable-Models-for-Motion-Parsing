function [labels1,labels2,map]=compute_color_labels_image_pair(image1,image2,nbColors);
[p1,q1,r]=size(image1);
[p2,q2,r]=size(image2);


X1=reshape(image1,p1*q1,r);
X2=reshape(image2,p2*q2,r);
X=[X1;X2];
nX=size(X,1);
X=reshape(X,[nX,1,r]);
[temp,map]=rgb2ind(X,nbColors,'nodither');
labels1=reshape(temp(1:p1*q1),p1,q1);
labels2=reshape(temp(p1*q1+1:end),p2,q2);
labels1=labels1+1;
labels2=labels2+1;


