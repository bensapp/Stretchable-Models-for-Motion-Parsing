if 0
    groundtruth = load2('groundtruth_Buffy_v2.1.mat')
else
    groundtruth = load2('groundtruth_PASCAL.mat')
end

%% load predictions from file and evaluate them
clear res
progbar(0,length(groundtruth))
for i=1:length(groundtruth)
    
    %load prediction
    [p,name,ext] = fileparts(groundtruth(i).filename);
    savefile = sprintf('%s/%s_final_prediction.mat',opts.outputdir,name);
    limb_guess = load2(savefile);

    % get proper scaling to original image size
    dims = cat(1,limb_guess.state_dims);
    scales = 1./bsxfun(@times,groundtruth(i).ex_size,1./dims(:,1:2));
    
    %evaluate using groundtruth
    [ncorrect,res(i,:)] = score_state_guess(limb_guess,groundtruth(i),scales);
    
    progbar(i,length(groundtruth))
end


%% print results summary over test set
if isfield(groundtruth,'istest')
    testinds = [groundtruth.istest];
else
    testinds = true(length(groundtruth),1);
end

names = {res(1,:).name};
fprintf('\n\n')
for i=1:length(names)
    fprintf('%s: %.02f\n',names{i},mean([res(testinds,i).is_correct])*100)
end
fprintf('------\ntotal: %.02f\n',mean([res(testinds,:).is_correct])*100)