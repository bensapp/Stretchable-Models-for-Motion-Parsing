function annquery_demo_2();
%ANNQUERY_DEMO A demo to show how to search and plot with ANN Wrapper
%
% [ History ]
%   - Created by Dahua Lin, on Aug 10, 2007
%

%%  Prepare Data Points
ref_pts = rand(2, 1000);

%{
coeff=5;
[x,y]=ndgrid(coeff*(1:30),1:30);
X=[x(:),y(:)];
X=X+rand(size(X))*1e-3;
%}


% query_pts = rand(2, 100000);
query_pts=ref_pts;

%% Do ANN query
k = 6;
tic;
nnidx = annquery(ref_pts, query_pts, k);
toc;

%% Plot the results
anngplot(ref_pts, query_pts, nnidx);
axis([0 1 0 1]);


0;
