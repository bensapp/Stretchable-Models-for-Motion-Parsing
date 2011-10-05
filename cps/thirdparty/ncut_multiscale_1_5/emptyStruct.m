function s=emptyStruct(fields,sizeStruct);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

res(nFiles,1)=emptyStruct([]);
res=emptyStruct(fields,[10,10]);
%}

if nargin<1
    fields={};
end
if nargin<2
    sizeStruct=[0,0];
end

if ischar(fields)
    fields={fields};
end

n=length(fields);
s=cell(2*n,1);
s(1:2:end)=fields(:);

s2={{}};
s2=s2(ones(n,1));
s(2:2:end)=s2;

if isempty(fields)
    s=struct([]);
else
    s=struct(s{:});
end

if nargin<2
    sizeStruct=[0,0];
end

if prod(sizeStruct)>0
    if isempty(s)
        if ~isempty(fields)
            s(prod(sizeStruct)).(fields{1})=[];
        end
    else
        s(prod(sizeStruct))=s;
    end
end

if ~isempty(sizeStruct)
    s=reshape(s,sizeStruct);
end
