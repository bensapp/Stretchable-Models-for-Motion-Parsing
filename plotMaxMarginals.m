function [guesspts,guessnames] = plotMaxMarginals(armstate_infos, max_marginals, t, imgdims, varargin)
% plots point clouds of states, with states plotted larger if they have a
% higher max marginal score after inference

% find only the t'th frame
frames = [armstate_infos.currframe];
[framerange, frameidx, tidx] = unique(frames);

idx = find(tidx==t);


p = [5 3 1 2 4 6];

dims = armstate_infos(idx(1)).dims;
% guesspts = ind2pts(dims, guesses(idx));
% guesspts = double(guesspts(1:2,p));

names = {armstate_infos.name};
guessnames = names(idx(p));

% guesspts = mapPoints2NewDims(guesspts, dims(1:2), imgdims);
hold on;

markersizes = [0 0 0 0 0 0 0 1 6 20];
colors = hsv(length(idx));
for k=1:length(idx)
    
    mmk = max_marginals(idx(k)).max_marginal;
    
    histedges = [];
    pcts = linspace(5,95,length(markersizes));
    for m=1:length(markersizes)
        histedges(m) = prctile(mmk,pcts(m));
    end
    
    [~,markerid]=histc(mmk,histedges);
    markerid = markerid+1;
    pts = ind2pts(armstate_infos(idx(k)).dims,armstate_infos(idx(k)).states);
    pts = double(pts(1:2,:));
    pts = mapPoints2NewDims(pts, dims(1:2), imgdims);
    
    for m=1:length(markersizes)
        midx = (markerid==m);
        if markersizes(m) == 0, continue, end
        plot(pts(1,midx),pts(2,midx),'.','markersize',markersizes(m),'color',colors(k,:));
    end
    
end
    
    

hold off;
