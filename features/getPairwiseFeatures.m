function [feat] = getPairwiseFeatures(treenodes, state_seq)
% For a given sequence of states, compute the sum pairwise feature vector

feat = cell(6);

for j = 1:numel(treenodes)
    if ~isempty(treenodes(j).valid_binary_inds)

        % find parent, and the corresponding part->part pair
        parent = treenodes(treenodes(j).parent);
        parid = parent.partid;
        id = treenodes(j).partid;

        % get parent's state in the given sequence
        parstate = state_seq(treenodes(j).parent).state_ind;

        % compute the index of the edge from parstate->this state
        n1 = length(treenodes(j).states);
        n2 = length(parent.states);
        ind2 = sub2ind2([n1 n2],state_seq(j).state_ind, parstate);

        if ~treenodes(j).valid_binary_inds(state_seq(j).state_ind, parstate)            
            error(['some state sequence for parts %s-->%s is not valid, ' ...
                'but SHOULD be valid, therefore true features will not be computed properly.'], ...
                parent.name, treenodes(j).name);
        end
        
        % add the features to the cumulative sum
        f = treenodes(j).binary_features(ind2,:)';
        if sum(f) == 0
            error('edge %s-%s (%d->%d) has zero features', ...
                parent.name, treenodes(j).name, ...;
                parstate, state_seq(j).state_ind);
        end
        
        if isempty(feat{parid, id})
            feat{parid,id} = f;
        else
            feat{parid,id} = feat{parid,id} + f;
%             feat{parid,id} = [feat{parid,id}  f];
        end
        
    end
end