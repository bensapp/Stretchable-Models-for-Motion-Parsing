function IG=computeSmoothedI(I,sigma);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

GaussianDieOff = .0001;
pw = 1:30; % possible widths
ssq = sigma*sigma;
width = max(find(exp(-(pw.*pw)/(2*sigma*sigma))>GaussianDieOff));
if isempty(width)
    width = 1;  % the user entered a really small sigma
end

t = (-width:width);
gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq);     % the gaussian 1D filter

IG=imfilter(I,gau,'conv','replicate');   % run the filter accross rows
IG=imfilter(IG,gau','conv','replicate'); % and then accross columns

%TODO:faster imfilter without lags
%{
IG1=conv2(I,gau,'same');   % run the filter accross rows
IG1=conv2(IG1,gau','same');   % run the filter accross rows
IG2=imfilter(I,gau);   % run the filter accross rows
IG2=imfilter(IG2,gau');   % run the filter accross rows
%}

%{
[x,y]=meshgrid(-width:width,-width:width);
dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);

ax = imfilter(aSmooth, dgau2D, 'conv','replicate');
ay = imfilter(aSmooth, dgau2D', 'conv','replicate');
%}

% function IG=computeSmoothedI_2(I,sigma);
% % s=21;
% s=17;
% G=computeGaussian([s,s],sigma);
% IG=correlation2d(I,G,'same');

