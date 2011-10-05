function X = featspair2mat(feats1,feats2,fnames)

f1= [];
f2= [];
pairfeats = [];
for i=1:length(fnames)
    
   f1 = [f1 feats1.(fnames{i}).unary_features];
   f2 = [f2 feats2.(fnames{i}).unary_features];
   pairfeats = [pairfeats feats1.(fnames{i}).binary_features];
end


pairfeats = reshape(full(pairfeats),[size(f1,1) size(f2,1) size(pairfeats,2)]);
feats1block = repmat(reshape(f1,[size(f1,1) 1 size(f1,2)]),[1 size(f2,1) 1]);
feats2block = repmat((permute(f2,[3 1 2])),[size(f1,1) 1 1]);
allfeats = cat(3,pairfeats,feats1block,feats2block);
X = reshape(allfeats,[prod(size2(allfeats,[1 2])) size(allfeats,3)]);