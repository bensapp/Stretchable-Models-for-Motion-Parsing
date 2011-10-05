function display_limb_guess(opts,limb_guess)
img = imread(opts.imgfile);
% display_limb_guesses(img,limb_guess)
legend off, cla, imagesc(img), axis image, hold on
for i=1:length(limb_guess)
    endpt1 = limb_guess(i).xyuv(1:2)';
    endpt2 = endpt1+limb_guess(i).part_dims(1)*limb_guess(i).xyuv(3:4)';
    endpts = [endpt1 endpt2];
    
    %need to scale to be same size as image
    s = size2(img,[2 1])'./limb_guess(i).state_dims([2 1])';
    endpts = endpts.*[s s];
    
    myquiver(endpts(:,1),diff(endpts,1,2),'g-')
    
end