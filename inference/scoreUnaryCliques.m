function [treenodes] = score_unary_cliques(treenodes, w)

for i=1:length(treenodes)

    % pick out the right weights
    unary_weights = w.unary_w{treenodes(i).partid};

    if ~isempty(treenodes(i).unary_features)
        % compute the scores
        scores = treenodes(i).unary_features*unary_weights;
        
        % there may be other contributions (e.g. HOGfilter) so just add them
        if isfield(treenodes(i), 'log_unary_clique') && ~isempty(treenodes(i).log_unary_clique)
            treenodes(i).log_unary_clique = treenodes(i).log_unary_clique + scores;
        else
            treenodes(i).log_unary_clique = scores;
        end
    end
end