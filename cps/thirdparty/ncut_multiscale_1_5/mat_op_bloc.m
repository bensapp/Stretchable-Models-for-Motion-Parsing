function C=mat_op_bloc(fun,maxSize,A,B);
%{
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

C=mat_op_bloc('A''A',[],A);
C=mat_op_bloc('A*B',[],A,B);
%}
if isempty(maxSize)
    maxSize=10000;%TODO:voir
end

[pA,qA]=size(A);
if nargin>=4
    [pB,qB]=size(B);
end

if maxSize<Inf
    nbBlocs=ceil(pA/maxSize);
    indexes=splitIndexes_equal(1:pA,nbBlocs);
    nIndexes=length(indexes);
else
    nIndexes=1;
end



assert(ischar(fun));
switch fun
    case 'A''A';
        if nIndexes==1
            C=A'*A;
            return;
        end
        C=zeros(qA,qA,class(A));
        for i=1:nIndexes
            indi=indexes{i};
            Ai=A(indi,:);
            C=C+Ai'*Ai;
        end
        
    case 'A*B';
        if nIndexes==1
            C=A*B;
            return;
        end
        C=zeros(pA,qB,class(A));
        for i=1:nIndexes
            indi=indexes{i};
            Ai=A(indi,:);            
            C(indi,:)=Ai*B;
        end
        
    otherwise
        assert(0);
end
