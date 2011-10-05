function [] = sanityCheckTreeModel(tn)

for i = 1:numel(tn)
    if tn(i).parent

        nzidx = find(sum(tn(i).binary_features,2));
        validx = find(tn(i).valid_binary_inds);

        assert( all(nzidx == validx) == true );
    end
end