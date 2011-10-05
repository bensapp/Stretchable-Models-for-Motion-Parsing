function [armstate_info] = makeInitialStatesFromCPS(example, larmlens, datadir, varargin)

defaults.keep_hands = 500;
defaults.topK_hands = 100;
defaults.topK_arms = 500;
defaults.use_marginals = false;
defaults.use_offset = false;
defaults.subsample_hands = 0;
defaults.arm_parts = 2:5;
defaults.smoothdims = 3;

opts = propval(varargin, defaults);

[~,fstem,~] = fileparts(example.imgfile);
filestem = [datadir,'/cps-features/',fstem];

state_info = loadvar([filestem,'_pruned_states.mat'],'state_info');

if opts.use_marginals
    max_marginals = load2([filestem '_final_marginals.mat'], 'max_marginals');
end

part_dims = loadvar('part_dims_80x80.mat');

armstate_info = example;

fginfo = load([filestem '_fg_color_detmaps.mat']);
face_smooth = scale01(blurimg(fginfo.face_color, opts.smoothdims));
torso_smooth = scale01(blurimg(fginfo.torso_color, opts.smoothdims));
color_smooth = face_smooth + torso_smooth;

%
tic
for p = 1:numel(opts.arm_parts)
    
    %%
    i = opts.arm_parts(p);

    if opts.use_marginals
        [mm sortidx] = sort(max_marginals(i).max_marginal,'descend');
    end
    
    bin2direction = get_articulated_dirs(state_info(i).state_dims(3));

    % swap left and right from ECCV names
    name = state_info(i).name;
    
    if name(1) == 'l', name(1) = 'r';
    elseif name(1) == 'r', name(1) = 'l';
    end
    state_info(i).name = name;

        
    %%
    j = getArmPartID(state_info(i).name);
    if j > 0
        
        if opts.use_marginals
            states = max_marginals(i).states(sortidx);
        else
            states = state_info(i).states;
        end
        armstate_info(j) = initstruct(armstate_info, example);

        armstate_info(j).name = state_info(i).name;
        armstate_info(j).partid = j;
        armstate_info(j).dims = [80 80 1];
        armstate_info(j).ul_offset = [0 0]';
        armstate_info(j).use_offset = opts.use_offset;
        
        pts = ind2pts(state_info(i).state_dims, states);
        
        [pts, bestrow] = unique(pts(1:2,:)', 'rows', 'first');

        if opts.use_marginals
            nk = min([length(bestrow) opts.topK_arms]);
            mmr = mm(bestrow);
            [mmr sortidxr] = sort(mmr, 'descend');
            
            pts = pts(sortidxr(1:nk),:)';
        else
            pts = pts';
        end
            
        pts(3,:) = 1;
        armstate_info(j).states = pts2ind(armstate_info(j).dims, pts)';
        armstate_info(j).unary_features_raw = [];
        armstate_info(j).unary_features = [];
        
    end
    %%
    % convert lower arm into hand states
    if state_info(i).name(end-3:end) == 'larm'

        if opts.use_marginals
            nk = min([length(state_info(i).states) opts.topK_hands]);
            states = max_marginals(i).states(sortidx(1:nk));
        else
            states = state_info(i).states;
        end

        name = [state_info(i).name(1) 'hand'];
        j = getArmPartID(name);
        
        armstate_info(j) = initstruct(armstate_info, example);
        armstate_info(j).name = name;
        armstate_info(j).partid = j;
        armstate_info(j).use_offset = opts.use_offset;
        if opts.use_offset
            armstate_info(j).dims = [120 120 1];
            armstate_info(j).ul_offset = [-20 -20]';
        else
            armstate_info(j).dims = [80 80 1];
            armstate_info(j).ul_offset = [0 0]';
        end
        
        handpts = [];
        elbowpts = [];
        
        % get elbow pts
        pts = double(ind2pts(state_info(i).state_dims,states));
        
        % get elbow direction
        uv = bin2direction(:,pts(3,:));
        
        handpts = repmat(pts(1:2, :), 1, numel(larmlens)) + kron(larmlens, uv);
       
        % now for every hand point, subsample
        if opts.subsample_hands > 0
            
            npts = size(handpts,2);
            subpts = ...
                [1 0 -1 0
                0 1 0 -1];
        
            handptsbak = handpts;
            for k = 1:size(subpts,2)                
                handpts = [handpts bsxfun(@plus, handptsbak, subpts(:,k).*opts.subsample_hands)];
            end


        end

        %elbowpts = round(bsxfun(@minus, elbowpts, armstate_info(j).ul_offset));
        handstatepts = round(bsxfun(@minus, handpts, armstate_info(j).ul_offset));
        
        handstatepts = unique(handstatepts', 'rows')';
        
        keepidx = find(handstatepts(1,:) <= armstate_info(j).dims(1) & ...
            handstatepts(1,:) > 0 & ...
            handstatepts(2,:) <= armstate_info(j).dims(2) & ...
            handstatepts(2,:) > 0);
        
        armstate_info(j).states = pts2ind(armstate_info(j).dims(1:2), ...
            handstatepts(1:2,keepidx))';
        
        
        % get color scores
        handscores = color_smooth(armstate_info(j).states);
        [ignore sortidx] = sort(handscores, 'descend');
        
        nk = min([numel(armstate_info(j).states) opts.keep_hands]);
        armstate_info(j).states = sort(armstate_info(j).states(sortidx(1:nk)));
        
        %armstate_info(j).elbowpts = elbowpts(:,keepidx);
        
        armstate_info(j).unary_features_raw = [];
        armstate_info(j).unary_features = [];
    end
end

return