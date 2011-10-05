function mval = maxFeatureInd(featinds)
if isempty(featinds), 
    mval = 0; 
    return; 
end

x = [];
f = fields(featinds);
for i=1:length(f)
    x = [x; vec(featinds.(f{i}))];
end
mval = max(x);