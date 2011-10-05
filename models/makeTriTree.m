function ttree = makeTriTree(submodels,frameidx)

%% construct 2-tree / "triangle"-tree

fb_msgs = cat(1,submodels.fwd_bwd_msgs);
trees = cat(1,submodels.tree);
% %for tree, prev_msgs, next_msgs, rows ~ submodels, cols ~ parts.
frameinds = find([trees(1,:).frame]==frameidx);
% prev_msgs = fb_msgs(:,[fb_msgs(1,:).frame]==(frameidx-1));
% next_msgs = fb_msgs(:,[fb_msgs(1,:).frame]==(frameidx+1));
curr_msgs = fb_msgs(:,[fb_msgs(1,:).frame]==frameidx);

nsubmodels = size(trees,1);
nparts = nsubmodels;

names = {trees(1,1:nparts).name};
nstates = cellfun(@length,{trees(1,frameinds).states});
clear ttree;
for i=1:length(names)-2
    ttree(i).names = names(i:i+2);
    ttree(i).nstates = nstates(i:i+2);
end


for i=1:nparts
    name2ind.(trees(1,i).name) = i;
end

for i=1:length(ttree)
    
    nodename = ttree(i).names{1};
    partind = name2ind.(nodename);
    
    % add up incoming messages
    m = curr_msgs(:,name2ind.(nodename));
    
    f = [m.me_and_kids_msgs_fwd];
    b = [m.bwd_max];
    
%     f = bsxfun(@minus,f,logsumexp2(f,1));
%     b = bsxfun(@minus,b,logsumexp2(b,1));
    
    ttree(i).unary = sum(f,2)+sum(b,2);
    
    %% collect edge scores
    ttree(i).pairwise = {};
    pairinds = [1 2; 1 3; 2 3];
    for p=1:size(pairinds,1)
        name1 = ttree(i).names{pairinds(p,1)};
        name2 = ttree(i).names{pairinds(p,2)};
        %% find edges that match name1 and name2
        edgepots = {};
        for s=1:nsubmodels
            for l=1:nparts
                name = trees(s,l+frameinds(1)-1).name;
                parentind = trees(s,l+frameinds(1)-1).parent;
                if parentind == 0, continue, end
                parentname = trees(s,parentind).name;
                
                if isequal(name,name1) && isequal(parentname,name2)
                    edgepots{end+1} = trees(s,l+frameinds(1)-1).log_binary_clique;  
                    vbi = trees(s,l+frameinds(1)-1).valid_binary_inds;
                    edgepots{end}(~vbi) = -realmax/1000;
                elseif isequal(name,name2) && isequal(parentname,name1)
                    edgepots{end+1} = trees(s,l+frameinds(1)-1).log_binary_clique';                    
                    vbi = trees(s,l+frameinds(1)-1).valid_binary_inds';
                    edgepots{end}(~vbi) = -realmax/1000;
                end
            end
            
        end
        e = sum(cat(3,edgepots{:}),3);
        ttree(i).pairwise{end+1} = e; % - logsumexp2(e(:));
        
    end
    % only 2 out of 3 edges are possible in each triangle:
    assert(sum(cellfun(@isempty,ttree(i).pairwise))==1)
end

%% in the last triangle, need to include the unary potentials of the last 2
%% parts (were not at the "head" of any other triangle so their unary terms have not been factored in yet)
for k=2:3
    nodename = ttree(end).names{k};
    partind = name2ind.(nodename);
    
    % add up incoming messages
    m = curr_msgs(:,name2ind.(nodename));
    
    f = [m.me_and_kids_msgs_fwd];
    b = [m.bwd_max];
    
%     f = bsxfun(@minus,f,logsumexp2(f,1));
%     b = bsxfun(@minus,b,logsumexp2(b,1));
    
    unary = sum(f,2)+sum(b,2);
    
    % have to stick them somehwere, so fold them into the pairwise term
    % (phi(B,C))
    if k==3
        unary = unary';
    end
    ttree(end).pairwise{end} = bsxfun(@plus,ttree(end).pairwise{end},unary);

    0;
end


%% clean up: make everything float (single), and fill in empty
% cliques

for i=1:length(ttree)
    ttree(i).unary = single(ttree(i).unary);
    for p=1:3
        if isempty(ttree(i).pairwise{p})
            ttree(i).pairwise{p} = zeros(ttree(i).nstates(pairinds(p,:)),'single');
        else
            ttree(i).pairwise{p} = single(ttree(i).pairwise{p});
        end
    end
end

