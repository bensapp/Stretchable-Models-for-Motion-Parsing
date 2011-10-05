function segments = prune_segments_size2(segments, size_th)

%
% prune_segments_size(segments, size_th)
% 
% Split segments which have several disconncted components and 
% remove segments whose area is smaller than size_th.
% Such small areas get label of largest neigboring segment.
%
% toshev@seas.upenn.edu
% 

labels = unique(segments);

% Removing all disconnected small segments
areas = zeros(max(labels),1);
disp_indx = [];
sg_count = max(labels)+1;
for c = 1:length(labels)
  % Finding all connected components of a segment
  msk = zeros(size(segments));
  msk(segments == labels(c)) = 1;
  bw = bwlabel(msk, 4);
  lb = setdiff(unique(bw), [0]);
  % Computing areas of the connected componnents
  areas_t = zeros(length(lb),1);
  for j = 1:length(lb)
     areas_t(j) = length(find(bw == lb(j)));
  end
  % Finding the biggest one
  [mv mi] = max(areas_t);
  % All other smaller connected components obtain a new label
  mm = setdiff(1:length(lb), mi);
  for j = 1:length(mm)
      segments(bw == lb(mm(j))) = sg_count;
      disp_indx = [disp_indx; sg_count];
      sg_count = sg_count + 1;
  end
  
  % Store the area of the largest conncted component of the current segment
  areas(labels(c)) = mv; %length(find(segments == labels(c)));
end

% Finding all segments of size smaller than a given threshold
small_indx = find(areas <= size_th & areas > 0);

% All segments which should be removed are (1) the smaller connected
% components of disconnected original segments; (2) small original segments
remove_indx = [disp_indx; small_indx];
retain_indx = setdiff(unique(segments), remove_indx);
areas_all = segment_areas(segments);

% Finding adjacency segment matrix
S = segment_meighbors(segments);

% Some of the segments for removal may have all adjacent segments
% for removal too -> modify S such that each segment for removal has
% at least one adjacent segment not for removal
degree = sum(S(remove_indx, retain_indx), 2);
while ~isempty(find(degree == 0))
   ii = find(degree == 0);
   for i = 1:length(ii)
      S(remove_indx(ii(i)), :) =  S(remove_indx(ii(i)), :)*S;
   end
   S = S + S';
   S(S > 0) = 1;
   degree = sum(S(remove_indx, retain_indx), 2);
end

% For all segments selected for removal
for i = 1:length(remove_indx)
    % Find adjacent ones with largest area 
    ii = find(S(remove_indx(i), retain_indx));
    [mv mi] = max(areas_all(retain_indx(ii)));
    % and assign its label
    segments(segments == remove_indx(i)) = retain_indx(ii(mi));
end
    


function areas = segment_areas(segments)
labels = unique(segments);
labels_nr = length(labels);
areas = zeros(labels_nr, 1);
for i = 1:labels_nr
    areas(labels(i)) = length(find(segments == labels(i)));
end

