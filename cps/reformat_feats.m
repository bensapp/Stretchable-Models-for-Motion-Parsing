function feats2 = reformat_feats(feats)
fnames = fields(feats);
nparts = length(feats.(fnames{1}));
for i=1:length(fnames)
   if ~isfield(feats.(fnames{i}),'unary_features')
       feats.(fnames{i})(1).unary_features = [];
   end
   if ~isfield(feats.(fnames{i}),'binary_features')
       feats.(fnames{i})(1).binary_features = [];
   end
end
for i=1:nparts
    for j=1:length(fnames)
        feats2(i).(fnames{j}) = feats.(fnames{j})(i);
    end
end
