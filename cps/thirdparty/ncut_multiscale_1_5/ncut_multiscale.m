function [classes,X,lambda,Xr,W,C,timing] = ncut_multiscale(image,nsegs,options);
% [classes,X] = ncut_multiscale(image,10);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                  %
%   Multiscale Normalized Cuts Segmentation Code   %
%                                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% inputs: 
% image: image to segment (size pxq or pxqx3)
% nsegs: number of segments requested
% outputs:
% classes: image regions (size pxq)
% X: eigenvectors (size pxqxnsegs)
% lamda: eigenvalues
% Xr: rotated eigenvectors (computed during discretisation)
% W: multiscale affinity matrix
% C: multiscale constraint matrix
% timing: timing information
% 
% source code available at http://www.seas.upenn.edu/~timothee
% Authors: Timothee Cour, Florence Benezit, Jianbo Shi
% Related publication:
% Timothee Cour, Florence Benezit, Jianbo Shi. Spectral Segmentation with
% Multiscale Graph Decomposition. IEEE International Conference on Computer
% Vision and Pattern Recognition (CVPR), 2005.
% 
% Please cite the paper and source code if you are using it in your work.


image=im2double(image);
[p,q,r] = size(image);

if nargin<3
    options=[];
end

%% compute multiscale affinity matrix W and multiscale constraint
%matrix C

if isfield(options, 'pb_file')
  load(options.pb_file);
               
  mPb_rsz = mPb_nmax_rsz;
  [r c k] = size(mPb_rsz);

  % any missing parameter is substituted by a default value
  par = [8,1,21,3];
  par(end+1:4)=0;
  j = (par>0);
  % make the filter size an odd number so that the responses are not skewed
  if mod(par(3),2)==0, par(3) = par(3)+1; end
  j = num2cell(par);
  [n_filter,n_scale,winsz,enlong] = deal(j{:});
  n = ceil(winsz/2);
  

  % filter to get phase info
  FBo = make_filterbank_odd2(8,1,21,3);

  % filter max_pb with FBo, this gets us 2nd derivative at each point/orientation
  f = [fliplr(mPb_rsz(:,2:n+1)), mPb_rsz, fliplr(mPb_rsz(:,c-n:c-1))];
  f = [flipud(f(2:n+1,:)); f; flipud(f(r-n:r-1,:))];
  Fpbo = fft_filt_2(f,FBo,1); 
  Fpbo = Fpbo(n+[1:r],n+[1:c],:);

  % select orientation using theta map
  P_map = zeros(r,c);
  tt = round(th_map*n_filter/pi);
  for t_i=1:n_filter
  P_map = P_map + (tt==(t_i-1)).*Fpbo(:,:,t_i);
  end

  % threshold to get phase
  pb_info.ephase = (P_map >= 0) - (P_map<0);
  pb_info.emag = mPb_rsz;
  options.pb_info = pb_info;
end


t= cputime;
[layers,C]=compute_layers_C_multiscale(p,q);
dataW = computeParametersW(image);
W=computeMultiscaleW(image,layers,dataW,options);
disp(['time compute W,C: ',num2str(cputime-t)]);

%% compute constrained normalized cuts eigenvectors
disp('starting multiscale ncut...');
t = cputime;
if ~isempty(C)
    [X,lambda,timing] = computeNcutConstraint_projection(W,C,nsegs);
else
    [X,lambda,timing] = computeKFirstEigenvectors(W,nsegs);
end
% disp(['time ncut: ',num2str(cputime-t)]);
% disp(['time W*X: ',num2str(timing.A_times_X)]);
% disp(['time dsaupd: ',num2str(timing.dsaupd)]);
% disp(['nbA_times_X: ',num2str(timing.nbA_times_X)]);

%% compute discretisation
[p,q,r]=size(image);
indPixels = (1:p*q)';
X = reshape(X(indPixels,:),p,q,nsegs);
t =cputime;
[classes,Xr] =discretisation(X);
disp(['time discretize: ',num2str(cputime-t)]);

