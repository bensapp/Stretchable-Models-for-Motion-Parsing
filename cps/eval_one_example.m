function results = eval_one_example(ex,limb_guess)
dims = cat(1,limb_guess.state_dims);
scales = 1./bsxfun(@times,ex.ex_size,1./dims(:,1:2));
[ncorrect,results] = score_state_guess(limb_guess,ex,0,scales);
