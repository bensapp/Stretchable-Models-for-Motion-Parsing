% dp_base = '~toshev/DAIN/ETHZShapeClasses/Mugs';
% dp_base = '~toshev/DAIN/ETHZShapeClasses/Bottles';
% dp_base = '~toshev/DAIN/ETHZShapeClasses/Giraffes';
% dp_base = '~toshev/DAIN/ETHZShapeClasses/Applelogos';
dp_base = '~toshev/DAIN/ETHZShapeClasses/Swans';

files = dir(fullfile(dp_base, '*.jpg'));

max_sz = 350;

for k = 1:length(files)
  
  files(k).name
  
  im = im2double(imread(fullfile(dp_base, files(k).name)));
  
  rsz = 1;
  if max(size(im)) > max_sz
    rsz = max_sz/max(size(im));
  end
  
  [mPb_nmax, mPb_nmax_rsz, bg1, bg2, bg3, cga1, cga2, cga3, ...
   cgb1, cgb2, cgb3, tg1, tg2, tg3, textons, th_map, mPb_all] = multiscalePb(im, rsz);

  fn_pb = fullfile(dp_base, [files(k).name '.pb.mat']);
  save(fn_pb, 'mPb_nmax', 'mPb_nmax_rsz', 'mPb_all', 'th_map');

end