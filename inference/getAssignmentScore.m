function [log_score, scores1, scores2] = getAssignmentScore(model,state_sequence) 

%each node is responsible for scoring its unary potential, and
%it's binary potential with its parent

if isfield(state_sequence,'state_ind')
    state_inds = [state_sequence.state_ind];
else
    state_inds = state_sequence;
end

% if ~isfield(state_sequence,'state_ind')
%     log_score = 0; scores1 = 0; scores2 = 0;
%     return
% end

%min_binary_val =mex_find_structarray_minval(model, 'log_binary_clique');

% min_binary_val =  min(vec(arrayfun(@(x)(min(x.log_binary_clique(:))),model,'uniformoutput',false)));

for i=1:length(model)
    model(i).score1 = model(i).log_unary_clique(state_inds(i));
    if model(i).parent == 0;
        model(i).score2 = 0;
    else
        
%         valid_edge = model(i).valid_binary_inds(state_inds(i), ...
%             state_inds(model(i).parent));
%         %valid_edge = true;
%         if ~valid_edge
%             model(i).score2 = min_binary_val;
%         else
            model(i).score2 = model(i).log_binary_clique(state_inds(i), ...
                state_inds(model(i).parent));
%         end
    end
end

%log score
scores1 = [model.score1];
scores2 = [model.score2];
log_score = sum(scores1) + sum(scores2);

return;
