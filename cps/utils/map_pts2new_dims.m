function [scaled_pts,scale_factor,scaled_inds] = map_pts2new_dims(state_pts,state_dims,scaled_dims)
% Maps points state_pts from current state_dims to new scaled_dims
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scale_factor = scaled_dims([2 1])' ./ state_dims([2 1])';
for i=1:2
    %upsample:
    if scale_factor(i)>1
        scaled_pts(i,:) = round((state_pts(i,:)-0.5)*scale_factor(i));
    %downsample:
    else
        scaled_pts(i,:) = round(state_pts(i,:)*scale_factor(i)+0.5);
    end
end
%fix: in case states split until out of bounds, put them back in
%bounds
scaled_pts(1,scaled_pts(1,:)<1)=1;
scaled_pts(2,scaled_pts(2,:)<1)=1;
scaled_pts(1,scaled_pts(1,:)>scaled_dims(2))=scaled_dims(2);
scaled_pts(2,scaled_pts(2,:)>scaled_dims(1))=scaled_dims(1);

if length(state_dims) == 3
    scaled_inds = sub2ind([scaled_dims state_dims(3)],scaled_pts(2,:),scaled_pts(1,:),state_pts(3,:));
else
    scaled_inds = sub2ind2(scaled_dims,scaled_pts(2,:),scaled_pts(1,:));
end

if 0
    imsc(zeros(scaled_dims(1:2)))
    hold on
    myplot(scaled_pts,'w.','markersize',30)
end