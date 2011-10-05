function hoginfo2 = flip_larm_rlarm_hoginfo(hoginfo)

flipmap = {
    'luarm','ruarm';
    'llarm','rlarm';
    };

names = {hoginfo.parts.name};
hoginfo2=hoginfo;
for i=1:size(flipmap,1)
    flipnames = flipmap(i,:);
    ind1 = find(strcmp(flipnames{1},names));
    ind2 = find(strcmp(flipnames{2},names));
    
    [hoginfo2.parts(ind1).name,hoginfo2.parts(ind2).name] = ...
        deal(hoginfo.parts(ind2).name,hoginfo.parts(ind1).name);
end
