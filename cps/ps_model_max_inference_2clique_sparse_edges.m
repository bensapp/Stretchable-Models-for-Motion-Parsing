function [state_seq,max_marginals,max_counts] = ps_model_max_inference_2clique_sparse_edges(ps_model,up_order,down_order)
% as opposed to the non-sparse-edges version, this assumes a sparse logical matrix field
% valid_binary_inds which denotes which edges are valid for msg passing
% only along those edges
rootind= find([ps_model.parent]==0);
todo = find(arrayfun(@(x)(isempty(x.children)),ps_model));
ps_model(1).fwd_max = [];
ps_model(1).fwd_argmax = [];
ps_model(1).used_count = [];

if nargin < 3
    up_order = get_upstream_order(ps_model);
    down_order = get_downstream_order(ps_model);
end

%replace invalid edge scores with a global minimum value
min_binary_val = min(vec(arrayfun(@(x)(min(x.log_binary_clique(:))),ps_model,'uniformoutput',false)));
min_unary_val = min(cat(1,ps_model.log_unary_clique));
n = length(ps_model);
min_val = (n-1)*min_binary_val + n*min_unary_val;


%fwd pass
for ind=up_order
        
    %multiply messages from all children with my unary potential
    me_and_kids_msgs = ps_model(ind).log_unary_clique;
    for i=1:length(ps_model(ind).children)
        me_and_kids_msgs = me_and_kids_msgs + ps_model(ps_model(ind).children(i)).fwd_max';
    end
    
    if ind == rootind
        ps_model(ind).max_marginal = me_and_kids_msgs;
        ps_model(ind).me_and_kids_msgs_fwd = me_and_kids_msgs;
        [state_seq(ind).val,state_seq(ind).state_ind] = max(me_and_kids_msgs);
        break;
    end
    
    [ps_model(ind).fwd_max,ps_model(ind).fwd_argmax] = ...
        sparse_msg_pass(me_and_kids_msgs,ps_model(ind).log_binary_clique,ps_model(ind).valid_binary_inds,'fwd',min_val);

    ps_model(ind).me_and_kids_msgs_fwd = me_and_kids_msgs;
   
%     assert(any(ps_model(ind).valid_binary_inds(ps_model(ind).gtind,:)))
end

0;


%backtrack to get max state, and do backwards viterbi to obtain max
%marginals
for ind=down_order(2:end)
    
    %compute marginal of part from parent's marginal and upstream message
    parent_max_marginal = ps_model(ps_model(ind).parent).max_marginal;
    
    %subtract off my incoming message
    parent_max_marginal = parent_max_marginal - ps_model(ind).fwd_max';
    
    %multiply parent marginal with binary clique, dim(2) corresponds to
    %parent, and sum out
     [bwd_max,bwd_argmax] = ...
        sparse_msg_pass(parent_max_marginal,ps_model(ind).log_binary_clique,ps_model(ind).valid_binary_inds,'bwd',min_val);

    %my marginal
    ps_model(ind).max_marginal = bwd_max + ps_model(ind).me_and_kids_msgs_fwd;
    ps_model(ind).bwd_argmax = bwd_argmax;
    
    %compute marginal of part from parent's marginal and upstream message
    state_seq(ind).state_ind = ps_model(ind).fwd_argmax(state_seq(ps_model(ind).parent).state_ind);
    state_seq(ind).val = ps_model(ind).fwd_max(state_seq(ps_model(ind).parent).state_ind);
    state_seq(ind).name = ps_model(ind).name;
   
end

%convert state indices into true states
state_seq = setfield2(state_seq,'name',{ps_model.name});
for i=1:length(ps_model)
    state_seq(i).state = ps_model(i).states(state_seq(i).state_ind);
end

%make max marginals it's own struct
max_marginals = rmfield2(ps_model,setdiff(fields(ps_model),{'name','max_marginal'}));

%don't calculate max_counts if not required:
if nargout <= 2, return; end

%% max marginal counts calculations:
% 1. propagate bwd counts to root
% 2. propagate fwd counts to leaves from root

%initialize 
ps_model(rootind).bwd_counts = 0;
leaf_nodes = find(cellfun(@isempty,{ps_model.children}));

%upstream pass, from leaves to root
nstates = cellfun(@length,{ps_model.states});
for ind=up_order
    x = ps_model(ind).bwd_argmax;
    pind = ps_model(ind).parent;
    weights = ones(nstates(ind),1);
    for i=1:length(ps_model(ind).children)
        kidind = ps_model(ind).children(i);
        weights = weights + ps_model(kidind).fwd_counts;
    end
    
    ps_model(ind).incoming_counts = weights-1;
    if ind==rootind
       ps_model(ind).max_counts = weights; 
       break;
    end
    c = mex_integer_histogram(int32(x),weights,int32(nstates(pind)));
    ps_model(ind).fwd_counts = c;
    
    %do edges too: put "weights" values on edge matrix entries
    %edge_counts holds edge counts b/w me (rows) and my parent (cols)
    ps_model(ind).fwd_edge_counts = sparse((1:nstates(ind))',ps_model(ind).bwd_argmax,weights,nstates(ind),nstates(ps_model(ind).parent));
    
    0;
end

%downstream pass, from root to leaves
for ind=down_order(2:end)
%     disp(ps_model(ind).name)
    pind = ps_model(ind).parent;
    
    x = ps_model(ind).fwd_argmax;
    weights = ps_model(pind).max_counts-ps_model(ind).fwd_counts;
    node_counts = mex_integer_histogram(int32(x),weights,int32(nstates(ind)));
    ps_model(ind).max_counts = node_counts+ps_model(ind).incoming_counts+1;
    
    %edges:
    bwd_edge_counts = sparse(ps_model(ind).fwd_argmax',(1:nstates(pind))',weights,nstates(ind),nstates(pind));
    ps_model(ind).max_edge_counts0 = bwd_edge_counts + ps_model(ind).fwd_edge_counts;
    ps_model(ind).max_edge_counts = ps_model(ind).max_edge_counts0(:);
%     disp(sum(ps_model(ind).max_edge_counts(:)))
end

max_counts = rmfield2(ps_model,setdiff(fields(ps_model),{'name','max_counts','max_edge_counts'}));
0;

function [msg_max,msg_argmax] = sparse_msg_pass(nodes,edges,valid_edges,pass_type,min_val)

% brute force, simple way:
%{
    if fwd:
    [msg_max,msg_argmax] = max(bsxfun(@plus,nodes(:),edges),[],1);
    
    if bwd:
    [msg_max,msg_argmax] = max(bsxfun(@plus,nodes(:)',edges),[],2);
%}

nodes = nodes(:);

if isequal(pass_type,'fwd')
    [inds1,inds2] = find(valid_edges);
    n2  = sparse(inds1,inds2,nodes(inds1),size(edges,1),size(edges,2),sum(valid_edges(:)));
    s = (n2+edges);
   
    assert(~isempty(inds1) && ~isempty(inds2))
    [msg_max,msg_argmax] = mex_row_max_sparse_inds(s,int32(inds1),int32(inds2));
    if any(msg_max<-1e100)
        0;
    end

elseif isequal(pass_type,'bwd')
    [inds1,inds2] = find(valid_edges);
    n2  = sparse(inds1,inds2,nodes(inds2),size(edges,1),size(edges,2),sum(valid_edges(:)));
    s = n2+edges;
    
    [msg_max,msg_argmax] = mex_row_max_sparse_inds(s',int32(inds2),int32(inds1));
%     assert(all(msg_argmax>0))

    msg_max = msg_max';
    msg_argmax = msg_argmax';   
    if any(msg_max<-1e100)
        0;
    end
else
    error('invalid message passing!')
end

%hack fix for invalid transitions, which have value approx realmin
% cutoff = -realmin*100;
% msg_max(msg_max<cutoff) = min_val;

function up_order = get_upstream_order(ps_model)
todo = find(arrayfun(@(x)(isempty(x.children)),ps_model));
for i=1:length(ps_model),ps_model(i).is_processed = false; end
up_order = [];
while 1
    %pop
    ind = todo(end);
    todo(end) = [];
    up_order(end+1)=ind;
    ps_model(ind).is_processed = true;
    
    if ps_model(ind).parent == 0;
        break;
    end
    
    %if me and all my siblings are done, my parent can be processed
    siblings = [ps_model(ps_model(ind).parent).children];
    alldone = all([ps_model(siblings).is_processed]);
    if alldone, todo = [ps_model(ind).parent todo]; end
end

function down_order = get_downstream_order(ps_model)
rootind= find([ps_model.parent]==0);
todo = rootind;
down_order = [];
while ~isempty(todo)
    
    %dequeue
    ind = todo(end);
    todo(end) = [];
    down_order(end+1) = ind;
    ps_model(ind).is_processed = true;

    %enqueue children
    todo = [ps_model(ind).children todo];
end

