function layers=computeLocationFromConstraints(C12,layers);
% compute each layers(i).location as samples from the finest layer
% each layer is a subsample of the finest layer
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


p=layers(1).p;
q=layers(1).q;
layers(1).location=1:layers(1).p*layers(1).q;
[X,Y]=ndgrid(1:layers(1).p,1:layers(1).q);

if length(layers)>1
    Ctemp=C12{1};
end
for i=2:length(layers)
    if i>2
        Ctemp=C12{i-1}*Ctemp;
    end
    xi=roundLimit(Ctemp*X(:),p);
    yi=roundLimit(Ctemp*Y(:),q);
    layers(i).location=sub2ind2([p,q],xi,yi);
end