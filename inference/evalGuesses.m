function [errs angs] =  evalGuesses(armstate_infos, guesses)

for p = 1:6

    pidx = find([armstate_infos.partid]==p);
    
    dims = armstate_infos(pidx(1)).dims;
    imgdims = armstate_infos(pidx(1)).imgdims;

    for i = 1:numel(pidx)
        trupts(:,i) = getGTPoints(armstate_infos(pidx(i)));
        
        
        pt = ind2pts(dims, armstate_infos(pidx(i)).gt_state);
        trustatepts(:,i) = double(pt(1:2,:));
    end
       
    guesspts = getPixPts(guesses(pidx), dims, imgdims);

    trustatepts = mapPoints2NewDims(trustatepts, dims(1:2), imgdims(1:2));

    tru_uv = diff(trustatepts,1,2);
    guess_uv = diff(guesspts,1,2);

    errs(p,:) = sqrt(sum([trupts - guesspts].^2));
    
    trackdot = sum(bsxfun(@times, tru_uv, guess_uv));
    
    tru_uv_n = bsxfun(@times, tru_uv, 1./[eps+sqrt(sum(tru_uv.^2))]);
    guess_uv_n = bsxfun(@times, guess_uv, 1./[eps+sqrt(sum(guess_uv.^2))]);

    truz  = all(tru_uv_n==0);
    guessz = all(guess_uv_n==0);

    matchz = truz & guessz;
    trackndot =sum(bsxfun(@times, tru_uv_n, guess_uv_n));

    trackndot(matchz) = 1;
  
    angs(p) = bundle(trackndot,tru_uv,guess_uv,tru_uv_n, guess_uv_n);
end

function [pts] = getPixPts(states, dims, imgdims)

   pts = ind2pts(dims, states);
   pts = mapPoints2NewDims(pts(1:2,:), ...
        dims(1:2), imgdims(1:2));
    
    