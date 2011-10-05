function display_c2f_states(state_info,imgdims)


clrs = lines(6);
dirs = angle2direction(get_articulated_angles(state_info(1).state_dims(3)));
for p=1:length(state_info)
    
    pts = ind2pts(state_info(p).state_dims,state_info(p).states) ;
    [scaled_pts,scale_factor,scaled_inds] = map_pts2new_dims(pts,state_info(p).state_dims,imgdims);
    uv = dirs(:,pts(3,:));
    
    myquiver(scaled_pts,7*uv,'linewidth',1,'color',clrs(p,:))
    
end
legend({state_info.name})

