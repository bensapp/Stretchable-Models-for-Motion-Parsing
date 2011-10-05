function [binary_features valid_binary_inds featinds] = computeBinaryFeatures(treenode, parent, datadir)

n1 = numel(treenode.states);
n2 = numel(parent.states);

% different binary features for different kinds of edges

if treenode.name == parent.name
    % case 1: purely tracking edge between two nodes of same type
    
    pts1 = ind2pts(treenode.dims, treenode.states);
    pts2 = ind2pts(parent.dims, parent.states);
    pts1 = double(pts1(1:2,:));
    pts2 = double(pts2(1:2,:));
    
    [binary_features_time_geom valid_binary_inds] = addBinaryTimePersistenceGeometry(treenode, parent);
    binary_features_time_color = addBinaryColorDistFeatures(treenode, parent, valid_binary_inds, 'l0');
    
    
    binary_features = [binary_features_time_geom  binary_features_time_color];
    
    featinds.time_geom = 1:size(binary_features_time_geom,2);
    featinds.time_color = size(binary_features_time_geom,2)+1:size(binary_features,2);
    0;
elseif treenode.name(2:end) == parent.name(2:end)
    % case 2: edge between two left/right symmetric body parts within frame
    
    valid_binary_inds = sparse(ones(n1,n2)>0);
    
    binary_features_cdist = addBinaryColorDistFeatures(treenode, parent, valid_binary_inds, 'chi2');
    binary_features_xorder = addBinaryXOrdering(treenode, parent, valid_binary_inds);
    
    binary_features = [binary_features_cdist binary_features_xorder];
    featinds.chi2color = 1:size(binary_features_cdist,2);
    featinds.symm_xorder = size(binary_features_cdist,2)+1:size(binary_features,2);
    0;
else
    % case 3: upper (uarm->larm) or lower arm (larm->hand)
    
    pts1 = ind2pts(treenode.dims, treenode.states);
    pts2 = ind2pts(parent.dims, parent.states);
    pts1 = double(pts1(1:2,:));
    pts2 = double(pts2(1:2,:));
    
    % 30 state length difference is all we accept
    valid_binary_inds = sparse(sqrt(XY2distances(pts1',pts2'))<30);
    %     valid_binary_inds = ensureGTEdge(valid_binary_inds, treenode, parent);
    
    fcolor = addBinaryColorDistFeatures(treenode, parent, valid_binary_inds, 'chi2');
    
    fcont = addBinaryContourAlignmentFeatures(treenode, parent, valid_binary_inds,datadir);
    
    fhog = addBinaryHOGDetmapFeatures(treenode, parent, valid_binary_inds,datadir);
    
    fflowfg = addBinaryFlowFGFeatures(treenode,parent,valid_binary_inds,datadir);
    
    %part specific geometry:
    if isequal(parent.name(2:end),'uarm') && isequal(treenode.name(2:end),'larm')
        fgeom = addBinaryUarmGeometry(treenode, parent, valid_binary_inds);
        binary_features = [fcolor fcont fhog fgeom fflowfg];
        
        featinds.chi2color = 1:size(fcolor,2);
        featinds.contours = featinds.chi2color(end)+1:featinds.chi2color(end)+size(fcont,2)/2;
        featinds.contoursflow = featinds.contours(end)+1:featinds.contours(end)+size(fcont,2)/2;
        featinds.hog = featinds.contoursflow(end)+1:featinds.contoursflow(end)+size(fhog,2);
        featinds.geom = featinds.hog(end)+1:featinds.hog(end)+size(fgeom,2);
        featinds.flowfg = featinds.geom(end)+1:featinds.geom(end)+size(fflowfg,2);
        
    else
        fgeom = addBinaryLarmGeometry(treenode, parent, valid_binary_inds);
        binary_features = [fcolor fcont fhog fgeom fflowfg];
        
        featinds.chi2color = 1:size(fcolor,2);
        featinds.contours = featinds.chi2color(end)+1:featinds.chi2color(end)+size(fcont,2)/2;
        featinds.contoursflow = featinds.contours(end)+1:featinds.contours(end)+size(fcont,2)/2;
        featinds.hog = featinds.contoursflow(end)+1:featinds.contoursflow(end)+size(fhog,2);
        featinds.geom = featinds.hog(end)+1:featinds.hog(end)+size(fgeom,2);
        featinds.flowfg = featinds.geom(end)+1:featinds.geom(end)+size(fflowfg,2);
    end
    
    if isequal(parent.name(2:end),'uarm') && isequal(treenode.name(2:end),'larm')
        if size(binary_features,2) ~= 72
            error('wrong number of features');
        end
    end
    
end

% for parts with same name (modulo left/right), add a repulsion feature
if isequal(treenode.name(2:end),parent.name(2:end))
    
end


%% sanity checking: features are correct size
assert(size(binary_features,1) == prod(size(valid_binary_inds)));
% sanity checking: correct # of edges HAVE features
nzidx = find(sum(binary_features,2));
validx = find(valid_binary_inds);
assert( all(nzidx == validx) == true );

