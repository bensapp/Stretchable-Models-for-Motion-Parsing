function [fb f] = fastdiscretize(x, nbins, minval, maxval)
% assumes x is in range [0 1] already
if isempty(x)
    [fb,f] = deal(x);
    return
end

if nargin < 3
    minval = 0;
    maxval = 1;
end

%scale to [0,1], truncating if overspills:
x = (x-minval)/(maxval-minval);
x(x<0) = 0;
x(x>1) = 1;

f = floor(x*nbins)+1; 
f(f>nbins) = nbins;

fb = [];
for j = 1:size(f,2)
    fb= [fb ind2vecpad(f(:,j)', nbins, size(f,1))'];
end


return

%% comparison to histc

x = rand(10000000,1);
tic
f = fastdiscretize(x, 10);
e1 = toc;
edges = 0:0.1:1;
tic
[n f] = histc(x, edges);
e2 = toc;
dispf('%g - %g = %g\n', e1, e2, e2-e1);

