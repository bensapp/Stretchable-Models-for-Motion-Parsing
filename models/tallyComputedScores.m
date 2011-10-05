function [scores edgeScores] = tallyComputedScores(tn,edgeInfo,scores,edgeScores)

if nargin==2
    for i = 1:numel(tn)
        scores(i).log_unary_clique = ...
            zeros(size(tn(i).log_unary_clique));
        scores(i).unary_count = 0;
    end
    edgeScores.lookupEdge = edgeInfo.lookupEdge;
    for i = 1:numel(edgeInfo.edges)
        e = rmfield2(edgeInfo.edges(i), ...
            {'binary_features','binary_features_transpose'});
        e.valid_binary_inds = full(e.valid_binary_inds);
        if e.flip_valid
            e.valid_binary_inds = ~e.valid_binary_inds;
        end
        
        e.log_binary_clique = zeros(size(e.valid_binary_inds));
        e.count = 0;
        edgeScores.edges(i) = e;
    end
end

for i = 1:numel(tn)
        
    if (tn(i).parent)
        
        
        edgeIdx = edgeInfo.lookupEdge(i, tn(i).parent);
        
        flip = false;
        if edgeIdx < 0
            flip = true;
        elseif edgeIdx == 0
            error('Edge not precomputed: (%d,%d)', i, tn(i).parent);
        end
        
        edge = edgeScores.edges(abs(edgeIdx));
            
        par_name = tn(tn(i).parent).name;
        
        % sanity check!!
        assert( ...
            (flip && strcmp(edge.par_name, tn(i).name) && strcmp(edge.child_name,par_name)) || ...
            (~flip && strcmp(edge.par_name, par_name) && strcmp(edge.child_name,tn(i).name)));

   
        s = tn(i).log_binary_clique;
        if flip
            s = s';
        end
        edgeScores.edges(abs(edgeIdx)).log_binary_clique = ...
            edgeScores.edges(abs(edgeIdx)).log_binary_clique + s;

        edgeScores.edges(abs(edgeIdx)).count = ...
            edgeScores.edges(abs(edgeIdx)).count + 1;
        
    end
    
    scores(i).log_unary_clique = scores(i).log_unary_clique + ...
        tn(i).log_unary_clique;
    scores(i).unary_count = scores(i).unary_count + 1;
 end
