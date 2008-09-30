function n_out=bigtic(n)
% Start timer for both elapsed time and cpu time. Use with bigtoc
%
%   >> bigtic           % Zero the default timer ('zeroth timer')
%   >> n = bigtic       % get an unused timer number, and zero that timer
%   >> bigtic(n)        % Zero the nth timer (n=1,2,...)

% T,G,Perring   22 July 2007

global t_elapsed_store t_cpu_store t_elapsed_store_arr t_cpu_store_arr

% Must call tic first if not already done
try
    t_tmp = toc;
catch
    tic
    t_tmp = toc;
end

% Fill stored times
if nargin==0
    if nargout==0
        t_elapsed_store=t_tmp;
        t_cpu_store=cputime;
    else
        n_out = length(t_elapsed_store_arr)+1;
        t_elapsed_store_arr(n_out)=toc;
        t_cpu_store_arr(n_out)=cputime;
    end
else
    t_elapsed_store_arr(n)=toc;
    t_cpu_store_arr(n)=cputime;
end

