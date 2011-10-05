function [vbe] = ensureGTEdge(vbe, treenode, parent)

c_gtidx = find(treenode.states==treenode.gt_state);
p_gtidx = find(parent.states==parent.gt_state);

if ~isempty(c_gtidx) && ~isempty(p_gtidx)
    vbe(c_gtidx,p_gtidx) = true;
%    warning('ensured GT edge that would have been false');
end