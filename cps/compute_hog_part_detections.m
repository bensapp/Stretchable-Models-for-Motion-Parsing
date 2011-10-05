function compute_hog_part_detections(img,opts)
num_angles = 24;
state_dims = [80 80 24];
angles = get_articulated_angles(num_angles);
models = load_models();

%% detect parts
parts = {};
for i=1:length(models)
    tic
    fprintf('--- %s ---\n',models(i).name)
    
    %limit angles where head and torso can be
    if isequal(models(i).name,'torso')
        angle_ids = num_angles/2;
    elseif isequal(models(i).name,'head')
        angle_ids = [1 num_angles-1 num_angles];
    else
        angle_ids = 1:num_angles;
    end
    
    results = detect_part(models(i),img,angles,angle_ids);
    detmaps.parts(i).detmap = imresize(results,state_dims(1:2));
    detmaps.parts(i).name = models(i).name;
  
    toc
end

savefile = fullfile(opts.outputdir,[opts.filestem,'_hog_detmaps.mat']);
mkdir2(savefile);
save(savefile,'-struct','detmaps');