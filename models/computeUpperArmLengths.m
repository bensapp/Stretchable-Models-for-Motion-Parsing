function [lengths] = computeUpperArmLengths(clips)

lengths = [];

for i = 1:numel(clips)
    for j = 1:numel(clips(i).examples)

        boxdim = boxsize(clips(i).examples(j).person.box);
        boxdim = boxdim(1);
        
        for ind = 1:5
            if isequal(clips(i).examples(j).person.parts(ind).name(2:end),'uarm')
                pts = clips(i).examples(j).person.parts(ind).pts;
                v0 = diff(pts,1,2);
                lengths = [lengths norm(v0)];
            end
        end            
    end
end
        