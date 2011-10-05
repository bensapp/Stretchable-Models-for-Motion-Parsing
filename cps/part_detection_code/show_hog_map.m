function varargout = show_hog_map(h,display_glyph_size)
w = foldHOG(h);
if nargin < 2
    display_glyph_size = 20;
end
[impos,imneg] = HOGpicture(w,display_glyph_size);

%oversaturate:
saturation = 2;
impos = uint8(saturation*255*scale01(impos));
imneg = uint8(saturation*255*scale01(imneg));

% impos=impos.^0.9;
if nargout == 0
    if all(imneg(:)==0)
        cla, imagesc(impos), axis image
        title(sprintf('num features = %d',numel(h)))
    else
        imagesc([impos imneg]); title('pos/neg weights'), axis image
        hold on
        plot(size2(impos,[2 2])+0.5,[1 size(impos,1)],'k-')
        plot(size2(impos,[2 2])+0.5,[1 size(impos,1)],'w:')
        hold off
    end
    colormap gray
else
    varargout{1} = impos;
    varargout{2} = imneg;
end

function f = foldHOG(w)
% f = foldHOG(w)
% Condense HOG features into one orientation channel.

f=w(:,:,1:9)+w(:,:,10:18)+w(:,:,19:27);
% f=w(:,:,10:18)+w(:,:,19:27);
% f=w(:,:,10:18);