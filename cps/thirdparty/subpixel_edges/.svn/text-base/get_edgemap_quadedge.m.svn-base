function [emag_all, ephase_all, x, y, gx, gy] = get_edgemap_quadedge(I, filter_par, threshold)
% a wrapper for color images to compute IC

imgh = size(I, 1);
imgw = size(I, 2);
nb_ch = size(I, 3);

emag_all = zeros([imgh imgw nb_ch]);
ephase_all = zeros([imgh imgw nb_ch]);

for ii  =1:nb_ch
    [x,y,gx,gy,par,threshold,emag,ephase,g,FIe,FIo,mago] = quadedgep_optimized2(I(:, :, ii),filter_par,threshold);
    emag_all(:, :, ii) = emag;
    ephase_all(:, :, ii) = ephase;
end;
