function bb = robustfit2(p)

rp = max(p) - min(p);
if rp(2) > rp(1)
  p = p(:,[2 1]);
end

warning off all;
b1 = robustfit(p(:,1), p(:,2));
warning on all;

if rp(2) > rp(1)
  bb = [b1(1) -1 b1(2)];   
else
  bb = [b1(1) b1(2) -1];   
end