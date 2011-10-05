function [tn] = pruneStates(tn, max_marginals, K)

tn = rmfield(tn,'unary_features');
tn = rmfield(tn,'binary_features');

for k = 1:numel(tn)
   
    mm = max_marginals(k).max_marginal;
    [tmp sortidx] = sort(mm,'descend');
    
    [tn(k).states neworder] = sort(tn(k).states(sortidx(1:K));
    tn(k).log_unary_clique = tn(k).log_unary_clique(sortidx(1:K));
    tn(k).log_unary_clique = tn(k).log_unary_clique(neworder);
end

% fix valid_binary_inds
for k = 1:numel(tn)
    
    if tn(k).parent
        states = tn(k).states;
        parstates = tn(tn(k).parent).states;
       
        vbi = tn(k).valid_binary_inds;
        [s p] = find(vbi);
        
        newidx = ismember(s, states)&ismember(p,parstates);
        
        s = s(newidx);
        p = p(newidx);
        
        inds = sub2ind(size(vbi), s, p);

        vbi = sparse(size(vbi,1),size(vbi,2));
        vbi(inds) = true;
        vbi = vbi>0;
        
        log_binary_clique = zeros(size(tn(k).log_binary_clique));
        
        invalid1 = ~ismember(1:row(vbi)
        
        
        
    end
    
end