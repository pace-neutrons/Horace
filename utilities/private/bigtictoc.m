function wout=bigtictoc(varargin)
% Start timer for both elapsed time and cpu time. Private for use with bigtic and bigtoc, so
% assumed that input is valid
%
%   >> bigtictoc('tic')             % Zero the default timer ('zeroth timer')
%   >> bigtictoc('tic',n)           % Zero timer n, or if not in use zero that timer
%   >> n=bigtictoc('tic')           % get an unused timer number, and zero that timer
%
%   >> t=bigtictoc('toc')           % times for default timer
%   >> t=bigtictoc('toc',n)         % times for timer n
%
%   >> bigtictoc('clear',n)         % clear timer n (cleans memory)
%   >> bigtictoc('clear','all')     % clear all timers (except the default)
%
% Store variables for bigtic and bigtoc
persistent t_elapsed_store t_cpu_store ntimer t_elapsed_store_arr t_cpu_store_arr

systime = 86400*datenum(clock);   % system time in seconds

if strcmp(varargin{1},'tic')
    if nargin==1
        if nargout==0
            t_elapsed_store=systime;
            t_cpu_store=cputime;
        else
            n=find_smallest_unused_timer(ntimer);
            ntimer=[ntimer,n];
            t_elapsed_store_arr(end+1)=systime;
            t_cpu_store_arr(end+1)=cputime;
            wout=n;
        end
    else
        n=round(varargin{2});
        if n==0 % default timer
            t_elapsed_store=systime;
            t_cpu_store=cputime;
        else
            ind=find(ntimer==n);
            if ~isempty(ind)
                t_elapsed_store_arr(ind)=systime;
                t_cpu_store_arr(ind)=cputime;
            else    % add timer to list and zero it
                ntimer=[ntimer,n];
                t_elapsed_store_arr(end+1)=systime;
                t_cpu_store_arr(end+1)=cputime;
            end
        end
    end

elseif strcmp(varargin{1},'toc')
    if nargin==1
        if ~isempty(t_elapsed_store)
            t(1)=systime-t_elapsed_store;
            t(2)=cputime-t_cpu_store;
        else
            disp(['WARNING: Default timer is uninitialised. Initialising now.'])
            bigtictoc('tic')
            t=bigtictoc('toc');
        end
    else
        n=round(varargin{2});
        if n==0 % default timer
            if ~isempty(t_elapsed_store)
                t(1)=systime-t_elapsed_store;
                t(2)=cputime-t_cpu_store;
            else
                disp(['WARNING: Default timer is uninitialised. Initialising now.'])
                bigtictoc('tic')
                t=bigtictoc('toc');
            end
        else
            ind=find(ntimer==n);
            if ~isempty(ind)
                t(1)=systime-t_elapsed_store_arr(ind);
                t(2)=cputime-t_cpu_store_arr(ind);
            else
                disp(['WARNING: Timer number ',num2str(n),' does not exist. Initialising now.'])
                bigtictoc('tic',n)
                t=bigtictoc('toc',n);
            end
        end
    end
    wout=t;

elseif strcmp(varargin{1},'clear')
    if isnumeric(varargin{2})
        n=round(varargin{2});
        if n~=0
            ind=(ntimer~=n);
            if ~all(ind) % timer is in the list
                ntimer=ntimer(ind);
                t_elapsed_store_arr=t_elapsed_store_arr(ind);
                t_cpu_store_arr=t_cpu_store_arr(ind);
            end
        else
            disp('WARNING: Cannot remove default timer. Function call ignored.')
        end
    elseif strcmpi(varargin{2},'all')
        ntimer=[];
        t_elapsed_store_arr=[];
        t_cpu_store_arr=[];
    end
else
    % debug info printed to screen
    disp(' ')
    disp( '       Timer                  time               CPU time     ')
    disp( '-------------------------------------------------------------------------------')
    disp(['    Default timer   ',num2str(t_elapsed_store,'%26.18g'),'    ',num2str(t_cpu_store,'%26.18g')])
    disp(' ')
    for i=1:numel(ntimer)
        disp(['              ',num2str(ntimer(i),'%8.0f'),'    ',num2str(t_elapsed_store_arr(i),'%26.18g'),'    ',num2str(t_cpu_store_arr(i),'%26.18g')])
    end
end


function n = find_smallest_unused_timer (ntimer)
if isempty(ntimer)
    n=1;
    return
else
    ntimer=sort(ntimer);
    ind=find(diff([0,ntimer])>1);
    if ~isempty(ind)
        if ind(1)==1
            n=1;
        else
            n=ntimer(ind(1)-1)+1;
        end
    else    % monotonic increasing
        n=numel(ntimer)+1;
    end
end

