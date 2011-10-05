function [ncorrect,res] = score_state_guess(ps_model,gtex,shrinks)

if nargin < 3, display = 0; end
if nargin < 4, shrink = 1; end
for p=1:length(ps_model)
    u = ps_model(p).xyuv(3:4)';
    u = u/norm(u);
    v = ps_model(p).part_dims(1)*u;
    endpts = [ps_model(p).xyuv(1:2)' ps_model(p).xyuv(1:2)'+v];
    endpts = endpts;

    gtparts = gtex.parts;
    gtpts = flipud(shrinks([p p],:)').*gtparts(strcmp({gtparts.name},ps_model(p).name)).pts;
    d = norm(gtpts(:,1) - gtpts(:,2));
	my_is_correct = all(sqrt(sum((endpts - gtpts).^2)) <= d/2);
    my_match_dist = (sqrt(sum((endpts - gtpts).^2)))/d;
    
    gt_u = gtpts(:,2) - gtpts(:,1);
    gt_u = gt_u / norm(gt_u);
    
    %ferrari's code
    pars.max_parall_dist = 0.5;
    pars.max_perp_dist = 0.5;
    [is_correct,match_score] = myDirectEvalSegms(endpts(:),gtpts(:),pars);
    
    
    res(p).name = ps_model(p).name;
    res(p).pts = endpts;
    res(p).is_correct = is_correct;
    res(p).match_score = match_score;
    res(p).my_match_dist = my_match_dist;
    res(p).my_is_correct = my_is_correct;
end
ncorrect = sum([res.is_correct]);

