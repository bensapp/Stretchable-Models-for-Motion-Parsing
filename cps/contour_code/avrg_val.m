function avals = avrg_val(nx, ny, vals)

[sx sy] = size(vals);

nx1 = ceil(nx); nx2 = floor(nx);
ny1 = ceil(ny); ny2 = floor(ny);

dx1 = nx1 - nx; dx2 = nx - nx2; 
dy1 = ny1 - ny; dy2 = ny - ny2;
d1 = 1./sqrt(dx1.^2 + dy1.^2 + eps);
d2 = 1./sqrt(dx1.^2 + dy2.^2 + eps);
d3 = 1./sqrt(dx2.^2 + dy1.^2 + eps);
d4 = 1./sqrt(dx2.^2 + dy2.^2 + eps);
d = d1 + d2 + d3 + d4;
d1 = d1./d; d2 = d2./d; d3 = d3./d; d4 = d4./d;

ii = find(nx1 <= sy & nx2 >= 1 & ny1 <= sx & ny2 >= 1);
avals = zeros(numel(nx), 1);

jj1 = sub2ind([sx sy], ny1(ii), nx1(ii));
jj2 = sub2ind([sx sy], ny2(ii), nx1(ii));
jj3 = sub2ind([sx sy], ny1(ii), nx2(ii));
jj4 = sub2ind([sx sy], ny2(ii), nx2(ii));

avals(ii) = d1(ii).*vals(jj1) + d2(ii).*vals(jj2) + d3(ii).*vals(jj3) ...
    + d4(ii).*vals(jj4);

