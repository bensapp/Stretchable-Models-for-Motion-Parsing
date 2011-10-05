function feats = compute_region_features(opts,state_info)

ncutfile = fullfile(opts.outputdir,[opts.filestem,'_ncut.mat']);
sp0 = load2(ncutfile,'Sp');
sp = int32(sp0);
spxy={};
[meshx,meshy]=meshgrid(1:size(sp,2),1:size(sp,1));
for k=1:max(sp(:))
    spek=(sp==k);
    spxy{k} = [vec(meshx(spek))'; vec(meshy(spek))'];
end 

names = {'llarm','rlarm','luarm','ruarm'};
for j=1:length(state_info)
    
    state_dims = state_info(j).state_dims;
    feats(j).name = state_info(j).name;
    feats(j).unary_features = [];
    feats(j).binary_features = [];
    if ~any(strcmp(names,feats(j).name)), continue, end;
%     fprintf('region features, %s...\n',state_info(j).name);
    
    states = state_info(j).states;
    part_length = 0.75*state_info(j).dims(1)*mean(size(sp))/state_dims(1);
    
    
    [ignore,ignore,scaled_states] = map_pts2new_dims(ind2pts(state_dims,states),state_dims,size(sp));
    endpts = states2endpts(scaled_states,[size(sp) state_dims(3)],part_length);

    feats(j).unary_features = compute_features(endpts,sp,spxy);
end


function feats = compute_features(endpts,sp,spxy)
dims  = size(sp);
maxsp = max(sp(:));
H = zeros(maxsp,size(endpts,3));

in_pct_thresh = 0.20;

for i=1:size(endpts,3)
    pts = round(endpts(:,:,i));
    [lx,ly] = intline2(pts(1,1),pts(1,2),pts(2,1),pts(2,2));
    lpts = [lx';ly'];
    lpts = lpts(:,~outOfBounds(dims,flipud(lpts)));
    lineinds1 = sub2ind(dims,lpts(2,:),lpts(1,:));
    
    h = mex_integer_histogram(sp(lineinds1),ones(length(lineinds1),1),maxsp)/length(lineinds1);
    
    %calculate moments along/perpendicular to line seg to get an idea of
    %spread
    mask_pts = [spxy{h > in_pct_thresh}];
    
    %special case
    if isempty(mask_pts), 
        var_x(i) = -1;
        var_y(i) = -1;
        continuity(i) = -1;
        continuity2(i) = -1;
        ctr_dists(i) = -1;
        convhull_ratio(i) = -1;
        convhull_numpts(i) = -1;
        continue
    end
    %     myplot(mask_pts)
    
    len_vec = endpts(:,2,i) - endpts(:,1,i);
    lv = len_vec/norm(len_vec);
    lv_orth = orthogonal_unit_vectors_2d(lv);
    
    ctr = mean(endpts(:,:,i),2);
    mask_ctr = mean(mask_pts,2);
    ctr_dists(i) = norm(ctr - mask_ctr);
    
    var_x(i) = var(mask_pts'*lv);
    var_y(i) = var(mask_pts'*lv_orth);
    
    maskinds = sub2ind(size(sp),mask_pts(2,:),mask_pts(1,:));
    is_continuous = ismember(lineinds1,maskinds);
    midcont = is_continuous(find(is_continuous,1,'first'):find(is_continuous,1,'last'));
    continuity(i) = mean(midcont);
    continuity2(i) = mean(is_continuous);
    
    
    %convex hull
    try
        [K,a] = convhull(mask_pts(1,:),mask_pts(2,:));
        convhull_ratio(i) = a/size(mask_pts,2);
        convhull_numpts(i) = length(K);
    catch
        convhull_ratio(i) = 0;
        convhull_numpts(i) = 0;
    end
    
    display = 0;
    if display
%         figure(1), imsc(sp)
        
        figure(2)
        cla,
        imagesc(double(h(sp)>in_pct_thresh)*500+double(sp)), axis image, hold on
        myplot(pts,'-','linewidth',3)
        myplot([ctr mask_ctr],'g.-');
        colormap gray
        drawellipse(mean(endpts(:,:,i),2),2*sqrt(var_x(i)),2*sqrt(var_y(i)),atan2(len_vec(2),len_vec(1)),'r-','linewidth',2)
        title(num2str(([var_x(i) var_y(i) continuity(i) continuity2(i) ctr_dists(i)  convhull_ratio(i)  convhull_numpts(i)])))
        drawnow
%         keyboard
    end
    0;
end

feats = [var_x(:) var_y(:) continuity(:) continuity2(:) ctr_dists(:)  convhull_ratio(:)  convhull_numpts(:)];
