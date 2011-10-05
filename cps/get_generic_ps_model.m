function ps_model0 = get_generic_ps_model(state_dims_new)
ps_model = load2('ps_model.mat','ps_model');
if ~iscell(state_dims_new)
    state_dims_new = repmat({state_dims_new},length(ps_model),1);
end
state_dims_orig = [110 122 24];
% ps_model0 = rmfield2(ps_model,setdiff(fields(ps_model),{'name','parent_name','dims','parent','children','mu'}));
ps_model0 = ps_model;
for i=1:length(ps_model0)
    part_scale = state_dims_orig(1:2)./state_dims_new{i}(1:2);
    ps_model0(i).dims = ps_model0(i).dims./part_scale;
    ps_model0(i).mu = ps_model0(i).mu./fliplr(part_scale)';
    ps_model0(i).state_dims = state_dims_new{i};
end