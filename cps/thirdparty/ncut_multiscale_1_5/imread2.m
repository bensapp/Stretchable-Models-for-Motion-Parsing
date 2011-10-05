function image = imread2(filename,maxSize,isGray);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

image = imread(filename);
if nargin >=3 && isGray
    if size(image,3)>1
        image = rgb2gray(image);
    end
end


if nargin > 1 && ~isempty(maxSize)
    [p,q,r] = size(image);
    if max(p,q)>maxSize
        factor = maxSize/max(p,q);
        try
            %may give Out of memory if image too large
            image = imresize(image,round([p,q]*factor),'bicubic');
        catch
            image = imresize(image,round([p,q]*factor));
        end            
    end
end

image = rescaleImage(double(image));
