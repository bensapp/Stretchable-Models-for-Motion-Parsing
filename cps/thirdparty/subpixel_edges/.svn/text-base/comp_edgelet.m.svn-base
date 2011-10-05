function [x,y,gx,gy] = comp_edgelet(img, para, ori_img, file_name);

if (nargin < 2)
    para.filter_par = [8, 1, 20, 3];
    para.edge_threshold = 0.1;
end

if (ischar(img))
    img = imread(img);
end

if (isfield(para, 'is_subsample') && para.is_subsample)
    img2 = img;
    img = ori_img;
end

img = double(img);
if (max(img(:)) > 1)
    img = img / 255;
end

img_h = size(img, 1);
img_w = size(img, 2);

% Edge detection
if (size(img, 3) > 1)
    img_gray = rgb2gray(img);
end

% Using qudedge
if (~isfield(para, 'detector') || strcmp(para.detector, 'quad'))
    [x,y,gx,gy,par,threshold,mag,mage,g,FIe,FIo,mago] = ...
        quadedge_subpixel(img_gray, para.filter_par, para.edge_threshold);
end

% Using pb or pb subpixel version
if (isfield(para, 'detector') && (strcmp(para.detector, 'pb') || strcmp(para.detector, 'pb_sub')))
    if (strcmp(para.detector, 'pb'))
        if (size(img, 3) > 1)
            [pb, theta] = pbCGTG(img);
        else
            [pb, theta] = pbBGTG(img);
        end
        [iy, ix] = find(pb > para.pb_thres);
        ind = iy+(ix-1)*img_h;
        x = [ix, ix];
        y = [iy, iy];
    else
        % Using pb subpixel
        if (size(img, 3) > 1)
            [pb, theta, px, py] = pbCGTG_subpixel(img);
        else
            [pb, theta, px, py] = pbBGTG_subpixel(img);
        end
        [iy, ix] = find(pb > para.pb_thres);
        ind = iy+(ix-1)*img_h;
        x = [ix, px(ind)];
        y = [iy, py(ind)];
    end
    gx = sin(theta(ind));
    gy = -cos(theta(ind));
end

% Using precomputed pb
if (isfield(para, 'detector') && ...
        (strcmp(para.detector, 'pb_pre') || strcmp(para.detector, 'pb_pre_small')))
    if (isempty(file_name))
        error('File name missing?');
    end
    [pathstr, name, ext, versn] = fileparts(file_name);
    if (strcmp(para.detector, 'pb_pre'))
        pb_file = fullfile(bsdsRoot(), 'pb_res', sprintf('%s_pb.mat', name));
    else
        pb_file = fullfile(bsdsRoot(), 'pb_res_small', sprintf('%s_pb.mat', name));        
    end
    data = load(pb_file);
    [iy, ix] = find(data.pb_sub > para.pb_thres);
    ind = iy+(ix-1)*img_h;
    x = [ix, data.px(ind)];
    y = [iy, data.py(ind)];
    gx = sin(data.theta(ind));
    gy = -cos(data.theta(ind));
end

% Subsample edgelets, to do here...
if (isfield(para, 'is_subsample') && para.is_subsample)
    imgh = size(img, 1);
    imgw = size(img, 2);
    mask = sparse(y(:,1), x(:,1), 1, imgh, imgw);
    img_gx = sparse(y(:,1), x(:,1), gx, imgh, imgw);
    img_gy = sparse(y(:,1), x(:,1), gy, imgh, imgw);
    mask2 = imresize(full(mask), [size(img2, 1), size(img2, 2)], 'nearest');
    [y, x] = find(mask2);
    img_gx = imresize(full(img_gx), [size(img2, 1), size(img2, 2)], 'bicubic');
    img_gy = imresize(full(img_gy), [size(img2, 1), size(img2, 2)], 'bicubic');
    gx = img_gx(y+(x-1)*size(img2, 1));
    gy = img_gy(y+(x-1)*size(img2, 1));    
end

figure;
disp_fragments(x, y, gx, gy);
