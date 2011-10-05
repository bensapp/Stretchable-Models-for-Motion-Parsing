function models = load_models()

load hog_lower_arms_boosting.mat llarm_model rlarm_model
load hog_upper_arms_boosting.mat luarm_model ruarm_model
load hog_upper_body_boosting.mat model; ub_model = model;
load hog_head_boosting.mat model; head_model = model;

luarm_model.name = 'luarm';
ruarm_model.name = 'ruarm';
llarm_model.name = 'llarm';
rlarm_model.name = 'rlarm';
ub_model.name = 'torso';
head_model.name = 'head';
models = [luarm_model ruarm_model llarm_model rlarm_model ub_model head_model];
for i=1:length(models)
    models(i).joint_loc = [0; -0.5].*fliplr(models(i).exdims)';
    models(i).flipimg = false;
    
    %use fewer rounds of boosting (for speed)
    models(i).classifiers = models(i).classifiers(1:1000);
    
    if isequal(models(i).name,'torso');
        models(i).joint_loc(2) = -models(i).joint_loc(2);
    end
    
    if isequal(models(i).name,'head')
        models(i).flipimg = true;
    end
    
end

