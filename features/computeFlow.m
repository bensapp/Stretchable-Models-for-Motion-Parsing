function computeFlow(example,img1,img2,opts)
MAXFLOWMAG = 4;

flow = c2f_optical_flow(img1,img2);
fm = sqrt(sum(flow.^2,3));
flow_scale = size2(flow,[1 2])./size2(img1,[1 2]);

meanval = mean(fm(:));
fgbox = scalebox(example.cropbox*mean(flow_scale),0.25);
fgmask = box2mask(fgbox,size(fm));
outliermask = fm > prctile(fm(:),75);
pts = [vec(flow(:,:,1))'; vec(flow(:,:,2))'];
bgpts = pts(:,~outliermask(:) & ~fgmask(:));
bgmotion = median(bgpts,2);

%subtract of bgmotion
flow(:,:,1) = flow(:,:,1) - bgmotion(1);
flow(:,:,2) = flow(:,:,2) - bgmotion(2);
fm = sqrt(sum(flow.^2,3));

%saturate
fm = fm / MAXFLOWMAG;
fm(fm>1) = 1;

%crop
fmcropped = extractWindow(fm,box2rhull(example.cropbox*mean(flow_scale)));

[~,filestem] = fileparts(example.imgfile);
savefile = sprintf('%s/flow/%s.mat',opts.datadir,filestem);
mkdir2(savefile)
save(savefile,'flow','fmcropped');