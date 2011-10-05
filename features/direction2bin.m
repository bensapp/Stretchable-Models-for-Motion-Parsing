function bins = direction2bin(dir,angles)
adirs = angle2direction(angles);

%one with largest dot product wins
closeness = dir'*adirs;
bins = argmax(closeness,[],2);