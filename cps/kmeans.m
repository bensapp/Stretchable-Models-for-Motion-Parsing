function [clusters, cluster_centers] = kmeans(data, cluster_nr, ...
                                              iter_nr, isverbal)

%
% K-means clustering algorithm
% Input: data - N x D matrix of N vectors of dimension D
%        cluster_nr - number of clusters
%        iter_nr - number of iterations
%
% Output: cluster_centers - cluster_nr x D matrix of the cluster
%                           centers
%         clusters - a cluster_nr dimensional vector of the cluster 
%                    assignment of each vector
% 
% This implementation uses k_d_trees.
%
% 2006 toshev@seas.upenn.edu

% addpath(genpath('/home/toshev/LIBS/kdtree'));
addpath(genpath('/home/toshev/LIBS/ann_1.1.1'));

if ~exist('isverbal', 'var')
  isverbal = true;
end

if isverbal
  fprintf('Starting k-means algorithm on %i points of dim %i\n', ...
          size(data,1), size(data,2));
end

[sz, dim] = size(data);

% init_ind = randperm(size(data,1));
r = rand(size(data,1),1); [sv init_ind] = sort(r);
cluster_centers = data(init_ind(1:cluster_nr),:);

if iter_nr > 0
    clustering = zeros(iter_nr, sz);
end

for i=1:iter_nr
    % fprintf('Starting iteration %i ...\n', i);
    % fprintf('Computing nearest cluster centers ...\n', i);
    % closest_points_idx = kdtreeidx(cluster_centers,data);
    closest_points_idx = annquery(cluster_centers',data',1);
    % fprintf('Computing new cluster centers ...\n', i);
    c = 1;
    old_c = 1;
    while c <= size(cluster_centers,1)
      ind  = find(closest_points_idx == old_c);
      if isempty(ind)
	cluster_centers = [cluster_centers(1:c-1,:); ...
			   cluster_centers(c+1:end,:)];
	fprintf(['No vector assignment to center %i. This center is' ...
		 ' removed.\n'], old_c);
      else
	cluster_centers(c,:) = mean(data(ind,:),1);
	c = c + 1;
      end
      old_c = old_c + 1;
    end
    
    if isverbal
      fprintf('.');
    end
end
if isverbal
  fprintf('\n');
end
clusters = annquery(cluster_centers',data',1);
