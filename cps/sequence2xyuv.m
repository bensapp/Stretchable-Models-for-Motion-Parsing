function state_guess = sequence2xyuv(ps_model,state_seq)
state_name2ps_ind = @(x)(find(strcmp({ps_model.name},x)));

part_dims = load2('part_dims_80x80.mat');

for p=1:length(ps_model)
    angles = get_articulated_angles(ps_model(p).state_dims(3));
    bin2direction = angle2direction(angles);
    
    pind = state_name2ps_ind(state_seq(p).name);
    ps_part = ps_model(pind);
    pt = ind2pts(ps_model(p).state_dims,state_seq(p).state);
    uv = bin2direction(:,pt(3));
    
    state_guess(pind).xyuv = [double(pt(1:2)) uv];
    state_guess(pind).name = ps_model(pind).name;
    state_guess(pind).part_dims = part_dims.(ps_model(pind).name);
    state_guess(pind).state_dims = ps_model(pind).state_dims;
end