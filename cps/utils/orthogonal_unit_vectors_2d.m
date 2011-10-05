function uv_orth = orthogonal_unit_vectors_2d(uv)
uv_orth = [-uv(2,:); uv(1,:)];
% u0inds = uv(1,:)==0;
% uv_orth(1,u0inds) = 1;
% uv_orth(2,u0inds) = 0;
uv_orth = bsxfun(@times,uv_orth,1./sqrt(sum(uv_orth.^2)));

% in the 2d plane there are 2 othogonal vectors to every vector.  remove
% ambiguity by enforcing right hand rule
pos_cross_prod = uv(1,:).*uv_orth(2,:) - uv(2,:).*uv_orth(1,:)>0;
uv_orth(:,pos_cross_prod) = -uv_orth(:,pos_cross_prod);

