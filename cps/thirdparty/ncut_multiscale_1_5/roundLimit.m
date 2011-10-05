function x = roundLimit(x,p);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

x = round(x);
x = max(min(x,p),1);