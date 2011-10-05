function progbar(num_done,num_total, lbltext)
% function progbar3(num_done,num_total, lbltext)
%

persistent starttime lastupdate last_str_len nested_idx

global noprogbar
if (~isempty(noprogbar) && noprogbar == 1) ||  (num_total == 1) 
        return
end

% Set defaults for variables not passed in
position = 0;
fractiondone = min(1,num_done/num_total);
percentdone = min(100,floor(100*fractiondone));

if nargin < 3, lbltext=''; end

% init
if num_done == 0 || nested_idx == 0
    
    if ~isempty(starttime), 
        nested_idx = nested_idx+1; 
    else
        nested_idx = 1;
    end
    
     % Set time of last update to ensure a redraw
    lastupdate(nested_idx,:) = clock - 1;
    last_str_len(nested_idx) = 0;
    
    % Task starting time reference
    if isempty(starttime) | (fractiondone == 0)
        starttime(nested_idx,:) = clock;
    end
       
end

% Enforce a minimum time interval between updates
if etime(clock,lastupdate(nested_idx,:)) < 0.05 && num_done < num_total
    return
end

runtime = etime(clock,starttime(nested_idx,:));
timeleft = runtime/(fractiondone+eps) - runtime;
timesofarstr  = sec2timestr(runtime);
timeleftstr = sec2timestr(timeleft);
status_string = sprintf('%03d/%03d - %03d%% - %s|%s',num_done,num_total,percentdone,timesofarstr,timeleftstr);

if ~isempty(lbltext)
    status_string = sprintf('%s: %s',lbltext,status_string);
end

w = 25;
chars_done = round(fractiondone*w);
second_line = ['[' repmat('=',1,chars_done-1) '>' repmat('.',1,w-chars_done) ']'];
if percentdone == 100, second_line = ['[' repmat('-',1,w) ']']; end
status_string = sprintf('%s : %s',status_string,second_line);
%nesting tabs, with at most 4 levels of indentation
status_string = sprintf('%s%s',repmat('  ',1,min(4,nested_idx-1)),status_string);

% if num_done>0, 
    %want to minimize time between these calls to avoid flickering
%     fprintf(repmat('\b',1,last_str_len(nested_idx)+1));
%     disp(status_string)
%     
        bs = sprintf(repmat('\b',1,1*(num_done>0)+last_str_len(nested_idx)));
%         java.lang.System.out.print(sprintf('%s',bs))
% %             pause(0.2)
%         java.lang.System.out.print(sprintf('%s',status_string))
%     java.lang.System.out.print(sprintf('%s%s',bs,status_string))
    disp(sprintf('%s%s',bs,status_string))
%     pause(0.2)
%     mex_print(s);
%     mex_print('%s',status_string);
% else
%     fprintf('\n');
%     fprintf('%s',status_string);
% end

last_str_len(nested_idx) = length(status_string);

% Record time of this update
lastupdate(nested_idx,:) = clock;


% If task completed, close figure and clear vars, then exit
if percentdone == 100 % Task completed
%     if nested_idx > 0
%         fprintf(repmat('\b',1,last_str_len(nested_idx)+1));
%     end
    starttime(nested_idx,:) = [];
    lastupdate(nested_idx,:) = [];
    last_str_len(nested_idx) = [];
    nested_idx = nested_idx - 1;

end

return
% ------------------------------------------------------------------------------


%% test

n = 901;
progbar(0,n) % Set starting time
for i = 1:n
  pause(0.1) % Do something important
  progbar(i,n,'this is a test') % Update text
end

%