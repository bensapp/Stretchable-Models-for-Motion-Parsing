function tf=verLessThan2(strNumber);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

temp=version;
temp = getParts(temp);
strNumber = getParts(strNumber);

tf = (sign(temp - strNumber) * [1; .1; .01]) < 0;
% tf = (sign(toolboxParts - verParts) * [1; .1; .01]) < 0;

function parts = getParts(V)
parts = sscanf(V, '%d.%d.%d')';
if length(parts) < 3
    parts(3) = 0; % zero-fills to 3 elements
end
