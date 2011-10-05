function [subImage,A]=extractWindow(image,rhull);
% Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

% subImage = extractBox(image,rhull2box(rhull),true);
% extractRotatedBox(box,img,do_mirror)

% return
% 
subImage=mex_extractWindow(image,rhull,1);
% if nargout>=2
%     A=translationMatrix([1;1]-vec(rhull([1,3])));
% end

function [subImage,A]=extractWindow_bak1(image,rhull);
%TODO: use images=mex_extractWindow(image,rhulls);

rhull=rhull(:)';
assert(length(rhull)==4);

%% rhull:x1,x2,y1,y2
size1=size(image);

[p,q,r]=size(image);

% A=register_rhulls(size2rhull([p,q]),rhull);%TODO: check validity when rhull not valid?
A=translationMatrix([1,1]-rhull([1,3]));

if numel(rhull)==2
    Lp=rhull(1);
    Lq=rhull(2);
    [subImage,A]=extractWindow(image,[Lp+1,p-Lp,Lq+1,q-Lq]);
    return;
end
% if isvector(rhull)
%     rhull=reshape(rhull,2,2)';
% end
if ~isvector(rhull)
    rhull=vec(rhull');
end

% subImage=image(rhull(1):rhull(2),rhull(3):rhull(4),:);

x1=rhull(1);
x2=rhull(2);
y1=rhull(3);
y2=rhull(4);

if (x1>=1 && x2<=p &&  y1>=1 && y2<=q)
    subImage=image(x1:x2,y1:y2,:);
else
    pw=x2-x1+1;
    qw=y2-y1+1;
    
    
    if islogical(image)
        subImage=false(pw,qw,r);
    else
        subImage=zeros(pw,qw,r,class(image));
    end
    
    X1=max(x1,1);
    X2=min(x2,p);
    Y1=max(y1,1);
    Y2=min(y2,q);
    subImage(1+X1-x1:pw+X2-x2,1+Y1-y1:qw+Y2-y2,:)=image(X1:X2,Y1:Y2,:);        
end

[p2,q2,r2]=size(subImage);
size1(1)=p2;
size1(2)=q2;
subImage=reshape(subImage,size1);

