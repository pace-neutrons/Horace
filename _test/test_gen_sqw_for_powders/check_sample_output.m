function  num_failed=check_sample_output(sample_file,tol,cuts_list,log_level)
%
%
if log_level>-1
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
end


old=load(sample_file);
nam=fieldnames(old);

num_failed = 0;
for i=1:numel(nam)
    cut_fun = cuts_list(nam{i});
    ws = cut_fun();
    %--------------------------------------------------------------------------------------------------
    % Visually inspect
    % acolor k
    % dd(ws)
    % acolor b
    % pd(w1_2)
    % acolor r
    % pd(w1_tot)
    %--------------------------------------------------------------------------------------------------
    
    [ok,mess]=equal_to_tol(ws,  old.(nam{i}), tol, 'ignore_str', 1,'min_denominator',1.);
    if ~ok
        warning('TEST_SAMPLE:fail','Error in test N %d for array %s\nMessage: %s',i,nam{i},mess)
        num_failed=num_failed+1;
    end
    
end


