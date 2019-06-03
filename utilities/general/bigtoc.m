function t = bigtoc(varargin)
% Read timer for both elapsed time and cpu time. Must call bigtic first to zero the timer
%
%   >> t = bigtoc
%   >> t = bigtoc(n)
%   >> t = bigtoc(...,mess)
%   >> t = bigtoc(...,mess,log_level)
%
% Input:
% ------
%   n           timer number (omit for default timer)
%   mess        [optional] message
%   log_level   [optional] log level, if this value > 1, the function prints
%               system time in the form: yyyy/mm/dd hh:mm:ss
%
% Output:
% -------
%   t           t(1)=elapsed wall time
%               t(2)=elapsed CPU time
%
%
% Original author: T.G.Perring
%
% $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)

display_time=false;
% Parse arguments
if nargin==0
    n=0;
    mess='';
elseif nargin==1
    if ischar(varargin{1})
        n=0;
        mess=varargin{1};
    elseif isnumeric(varargin{1})
        n=varargin{1};
        mess=['Timer ',int2str(n),':'];
    else
        disp('WARNING: Check arguments to bigtoc. Function call ignored.')
    end
else
    if isnumeric(varargin{1}) && (ischar(varargin{2})|| isempty(varargin{2}))
        n=varargin{1};
        mess=varargin{2};
    elseif ischar(varargin{1}) && (isnumeric(varargin{2}))
        n=0;
        mess=varargin{1};
        if varargin{2}>1
            display_time=true;
        end
    else
        disp('WARNING: Check arguments to bigtoc. Function call ignored.')
    end
    if nargin>2
        if isnumeric(varargin{3})
            if varargin{3}>1
                display_time=true;
            end
        else
            disp('WARNING: Check third argument to bigtoc. Function call ignored.')
        end
    end
end

% Perform function
t_tmp=bigtictoc('toc',n);
if nargout==0
    if ~isempty(mess); disp(mess); end;
    disp(['Elapsed time is ',num2str(t_tmp(1)),' seconds'])
    disp(['    CPU time is ',num2str(t_tmp(2)),' seconds'])
    if display_time
        fprintf(' System time is  %4d/%02d/%02d %02d:%02d:%02d\n',fix(clock));        
    end
else
    t=t_tmp;
end
