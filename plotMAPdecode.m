function [guesspts,guessnames] = plotMAPdecode(armstate_infos, guesses, t, imgdims, varargin)


% find only the t'th frame
frames = [armstate_infos.currframe];
[framerange, frameidx, tidx] = unique(frames);

idx = find(tidx==t);


p = [5 3 1 2 4 6];

dims = armstate_infos(idx(1)).dims;
guesspts = ind2pts(dims, guesses(idx));
guesspts = double(guesspts(1:2,p));

names = {armstate_infos.name};
guessnames = names(idx(p));

guesspts = mapPoints2NewDims(guesspts, dims(1:2), imgdims);
hold on;
if nargin==3
    myplot(guesspts, '-oc','MarkerFaceColor','cyan');
elseif 0
%     myplot(guesspts(:,2:end-1), varargin{:});
    myplot(guesspts(:,[1 2 3]), varargin{:});
    myplot(guesspts(:,[4 5 6]), varargin{:});
    
    
elseif 1
    
    
    % plot two sets of arms
    x = guesspts;
    
    h = plot(x(1,1:3),x(2,1:3),varargin{:});
    h = plot(x(1,4:6),x(2,4:6),varargin{:});
    
    
elseif 0
    for i=1:size(guesspts,2)-1
       pts2 = guesspts(:,i:i+1);
       l = diff(pts2,1,2);
       w = orthogonal_unit_vectors_2d(l)*20; %norm(l)*0.125;
       box = [pts2(:,1)-w pts2(:,1)+w pts2(:,2)+w pts2(:,2)-w];
       plotboxrot(box,'g-')
%        myplot(pts2,'w-')
    end
end
hold off;
