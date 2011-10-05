function angle = dir2angle(dir)
dir = bsxfun(@times,dir,1./sqrt(sum(dir.^2,1)));
angle = wraprad(atan2(dir(2,:),dir(1,:)) - pi/2);