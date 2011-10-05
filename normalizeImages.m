function [examples] = normalizeImages(imgfiles, torsoboxes, opts)

outputdir = opts.datadir;

boxctrs = boxcenter(torsoboxes);
boxszs = boxsize(torsoboxes);
boxareas = sqrt(prod(boxszs,2));
n = length(imgfiles);

boxctrs_smooth = [blurimg(boxctrs(1,:),13);blurimg(boxctrs(2,:),13)];
boxareas_smooth = blurimg(boxareas,13);

% boxctrs_smooth = boxctrs;
% boxareas_smooth = boxareas;

t = CTimeleft(numel(imgfiles));
for j = 1:numel(imgfiles)
    t.timeleft;
    img = imread(imgfiles{j});
    
    boxw = boxareas_smooth(j);
    boxh = boxw/opts.imgdims(2)*opts.imgdims(1);
    cropbox = box_from_dims(boxw,boxh,boxctrs_smooth(:,j));
    cropbox = scalebox(cropbox,3.625);
    
    
%         clf
%         imagesc(img)
%         hold on
%         plotbox(cropbox,'m-');
%     
%         plotbox(gtcropboxes(j,:),'g-')
%         axis image ij
%         drawnow
%     
%         continue
    cropped_im = extractWindow(img, box2rhull(cropbox)); %imcropfill(img, rect);
    
    cropped_im = imresize(cropped_im,opts.imgdims,'bilinear');
    
    savefile = sprintf('%s/normalized-images/%08d.jpg',opts.datadir,j);
    mkdir2(savefile);
    imwrite(cropped_im,savefile);
    
    
    examples(j).imgdims = opts.imgdims;
    examples(j).imgdims_orig = size(img);
    examples(j).cropbox = cropbox;
    examples(j).imgfile = savefile;
    examples(j).imgfile_orig = imgfiles{j};
    
    
end

return;
