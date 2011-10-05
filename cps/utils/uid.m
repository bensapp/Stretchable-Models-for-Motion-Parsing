function u = uid(nchar)

if usejava('jvm')
    u = strrep(char(java.util.UUID.randomUUID),'-','');
else
    u = num2str(feature('timing','cpucount'));
end

if nargin
    assert(length(u)>=nchar);
    u = u(1:nchar);
end