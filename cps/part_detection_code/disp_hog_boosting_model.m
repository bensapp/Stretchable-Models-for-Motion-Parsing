function disp_hog_boosting_model(model)
inds = [model.classifiers.index_feature];
[feat_y,feat_x,feat_z] = ind2sub(model.hogdims,inds);

thresh = [model.classifiers.thres];
lowvals = [model.classifiers.v1];
highvals = [model.classifiers.v2];

[w_thresh,w_low,w_high,w_both] = deal(zeros(model.hogdims));
for i=1:length(inds)
    w_thresh(inds(i)) = w_thresh(inds(i)) + thresh(i);
    w_low(inds(i)) = w_low(inds(i)) + lowvals(i);
    w_high(inds(i)) = w_high(inds(i)) + highvals(i);
    w_both(inds(i)) = w_both(inds(i)) + highvals(i)-lowvals(i);
end

show_hog_map(w_both,20), set(gcf,'name',sprintf('%s model',model.name)),
0;