function t = bigtoc(varargin)
% Read timer for both elapsed time and cpu time. Must call bigtic first to zero the timer
%
%   >> t = bigtoc(mess)
%   >> t = bigtoc(n,mess)
%
%   n       timer number (omit for defautl timer)
%   mess    [optional] message
%
%   t       t(1)=elapsed wall time
%           t(2)=elapsed CPU time

% T.G.Perring 22 July 2007

global t_elapsed_store t_cpu_store t_elapsed_store_arr t_cpu_store_arr

% Parse arguments
if nargin==0
    n=0;
    mess='';
elseif nargin==1
    if ischar(varargin{1})
        n=0;
        mess=varargin{1};
    else
        n=varargin{1};
        mess=['Timer ',int2str(n),':'];
    end
else
    n=varargin{1};
    mess=varargin{2};
end

% get timings
if n==0
    t_elapsed_tmp=toc-t_elapsed_store;
    t_cpu_tmp=cputime-t_cpu_store;
else
    t_elapsed_tmp=toc-t_elapsed_store_arr(n);
    t_cpu_tmp=cputime-t_cpu_store_arr(n);
end
if nargout==0
    if ~isempty(mess); disp(mess); end;
    disp(['Elapsed time is ',num2str(t_elapsed_tmp),' seconds'])
    disp(['    CPU time is ',num2str(t_cpu_tmp),' seconds'])
else
    t(1)=t_elapsed_tmp;
    t(2)=t_cpu_tmp;
end
