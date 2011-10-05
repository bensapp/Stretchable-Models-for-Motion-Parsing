function image2=rgb2lab(image);
% Timothee Cour, 28-Jul-2008 15:19:29 -- DO NOT DISTRIBUTE

cform = makecform('srgb2lab');
image2 = applycform(image,cform);
