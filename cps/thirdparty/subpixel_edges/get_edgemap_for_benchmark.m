function [emag_disp, emag_temp] = get_edgemap_for_benchmark(I, filter_par, threshold)

% filter_par = [4,1,12,3];
%     threshold = 1e-3;
    imgh = size(I, 1);
    imgw = size(I, 2);

    [emag, ephase, zx, zy] = get_edgemap_quadedge2(double(I), filter_par, threshold);
    zx = max(1, min(imgw, round(zx)));
    zy = max(1, min(imgh, round(zy)));

    emag_temp = max(emag,[], 3);
    emag_temp = emag_temp / max(emag_temp(:)) * 255;
    eind_map = sparse(zy, zx, 1, size(I,1), size(I,2));

    ind = find(eind_map > 2);
    emag_disp = zeros(size(emag_temp));
    emag_disp(ind) = emag_temp(ind);
    emag_disp = uint8(emag_disp);
