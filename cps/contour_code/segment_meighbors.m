function N = segment_meighbors(segments)

% 
% N = segment_meighbors(segments)
% 
% Computes an adjacency matrix N (of size #labels x #labels)
% which has value N(i, j) = 1 if segments with labels i and j 
% have common boundary points, otherwise N(i, j) = 0;
%
% toshev@seas.upenn.edu
% 

labels = unique(segments);
labels_nr = length(labels);
st = strel('disk', 1);
N = zeros(max(labels));

for i = 1:labels_nr
    msk = zeros(size(segments));
    msk(segments == labels(i)) = 1;
    msk = imdilate(msk, st);
    neigbor_labels = setdiff(unique(segments(msk == 1)), labels(i));
    N(labels(i), neigbor_labels) = 1;
end

N = N + N';
N(N > 0) = 1;

% Debugging code
if(0)
    % Visualizes for a selected segment all
    % adjacent segments
    % Select a segment label
    sel_label = 10
    labels = unique(segments);
    msk = zeros(size(segments));
    msk(segments == labels(sel_label)) = 2;
    nb = find(N(labels(sel_label), :));
    for i = 1:length(nb)
        msk(segments == nb(i)) = 1;
    end
    figure; imagesc(msk);
end