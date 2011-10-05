function [tn] = insertPrecomputedFeatures(tn, edgeInfo, featuresel)

if nargin == 3 && ~isempty(featuresel)
    [tn edgeInfo] = selectFeatures(tn,edgeInfo,featuresel);
end

for i = 1:numel(tn)

    if tn(i).parent

        edgeIdx = edgeInfo.lookupEdge(i, tn(i).parent);
        
        flip = false;
        if edgeIdx < 0
            flip = true;
        elseif edgeIdx == 0
            error('Edge not precomputed: (%d,%d)', i, tn(i).parent);
        end

        edge = edgeInfo.edges(abs(edgeIdx));
        
        par_name = tn(tn(i).parent).name;
        
        % sanity check!!
        assert( ...
            (flip && strcmp(edge.par_name, tn(i).name) && strcmp(edge.child_name,par_name)) || ...
            (~flip && strcmp(edge.par_name, par_name) && strcmp(edge.child_name,tn(i).name)));

        tn(i).valid_binary_inds = edge.valid_binary_inds;

        if edge.flip_valid, tn(i).valid_binary_inds = ~tn(i).valid_binary_inds; end;

        if flip                    
            tn(i).valid_binary_inds = tn(i).valid_binary_inds';
            tn(i).binary_features = edge.binary_features_transpose;
        else            
            tn(i).binary_features = edge.binary_features;            
        end
        
    
        % sanity checking: features are correct size
        assert(size(tn(i).binary_features,1) == prod(size(tn(i).valid_binary_inds)));
    
        if 1 && isequal(edge.par_name,edge.child_name)
            
            parent = tn(tn(i).parent);
            treenode = tn(i);
            
            pts1 = ind2pts(treenode.dims, treenode.states);
            pts2 = ind2pts(parent.dims, parent.states);
            pts1 = double(pts1(1:2,:));
            pts2 = double(pts2(1:2,:));

            %scale points to be in [0,1]
            pts1 = bsxfun(@times, pts1, 1./treenode.dims([2 1])');
            pts2 = bsxfun(@times, pts2, 1./parent.dims([2 1])');
    
            D = sqrt(XY2distances(pts1',pts2'));
            vbi = sparse(D <= 5/80);
%             vbi = ensureGTEdge(vbi, treenode, parent);
            tn(i).valid_binary_inds = vbi;
        end
            
        
        % sanity checking: correct # of edges HAVE features
        %nzidx = find(sum(tn(i).binary_features,2));
        %validx = find(tn(i).valid_binary_inds);
        %assert( numel(nzidx)==numel(validx) && all(nzidx == validx) == true );
        
    end
end

% check validity of chain by computing GT features
%tru_state_seq = getGTAssignments(tn);
%feat = getPairwiseFeatures(tn, tru_state_seq);



