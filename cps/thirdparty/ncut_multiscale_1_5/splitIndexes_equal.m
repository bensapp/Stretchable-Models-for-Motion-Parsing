function indexes=splitIndexes_equal(ind1,N);
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

assert(N>0);
n=length(ind1);
indexes=cell(N,1);

x=round(linspace(1,n,N+1));
i2=0;
for i=1:N
%     i1=x(i);
%     i2=x(i+1)-1;
    i1=i2+1;
    i2=floor(x(i+1));
    if i==N
        i2=n;%just to make sure
    end    
    indexes{i}=ind1(i1:i2);
end
% assert();
