function [pct guesses] = argmaxagreement(mmarg_info)

%%
for j = 1:numel(mmarg_info)
    guesses(j,:) = [mmarg_info(j).max_state_seq.state];
end

agree = bsxfun(@eq, guesses, mean(guesses));
pct = mean(all(agree));

