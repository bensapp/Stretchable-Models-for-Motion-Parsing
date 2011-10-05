function angles = get_articulated_angles(nbAngles)
default_num = 24;
angles = (linspace(0,360,default_num+1)-180)*pi/180;
angles = angles(2:end);
if nbAngles ~= default_num
   %home-brewed interpolation
   s = default_num/nbAngles;
   angles = (angles(1:s:end)+angles(2:s:end))/2;
end
