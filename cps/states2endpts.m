function endpts = states2endpts(states,state_dims,part_length)
pts = double(ind2pts(state_dims,states));
angles = get_articulated_angles(state_dims(3));
joints = pts(1:2,:);
uv = angle2direction(angles(pts(3,:)));
endpts = joints+uv*part_length;
endpts = [reshape(joints,[2 1 size(joints,2)]) reshape(endpts,[2 1 size(endpts,2)])];