function states_filtered = smoothSequence(dims,states)
nparts = 6;
N = 3;
S = reshape(states,nparts,numel(states)/nparts);
for i=1:nparts
    pts = ind2pts(dims,S(i,:));

    %median filter to smooth
    ptsfilt  = [medfiltpad(pts(1,:),N); medfiltpad(pts(2,:),N)];
    
    if 0
        %%
        clf, axis([1 80 1 80]), axis ij
        for k=1:size(pts,2)
            cla
            myplot(pts(:,k))
            hold on
            myplot(ptsfilt(:,k),'mo')
            axis([1 80 1 80]), axis ij
            pause(.1)
            drawnow
        end
    end
    
    sfilt = sub2ind(dims,ptsfilt(2,:),ptsfilt(1,:));
    Sfilt(i,:) = sfilt;
    0;
end

states_filtered = Sfilt(:)';

function xout = medfiltpad(x,N)

% x = sin(linspace(0,2*pi,100)) + 0.1*randn(1,100)+10

buf1 = repmat(x(1),[1 N]);
buf2 = repmat(x(end),[1 N]);
xm = medfilt1([buf1 x buf2],N);
xout = xm(N+1:end-N);

%{
clf, hold on
plot(1:100,x)
plot((1-N):(100+N),xm,'g-')
plot(1:100,xout,'k-')
%}


