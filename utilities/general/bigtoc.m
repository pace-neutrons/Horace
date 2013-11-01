function t = bigtoc(varargin)
% Read timer for both elapsed time and cpu time. Must call bigtic first to zero the timer
%
%   >> t = bigtoc
%   >> t = bigtoc(n)
%   >> t = bigtoc(...,mess)
%
%   n       timer number (omit for default timer)
%   mess    [optional] message
%
%   t       t(1)=elapsed wall time
%           t(2)=elapsed CPU time
%

% Original author: T.G.Perring
%
% $Revision$ ($Date$)


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
    if isnumeric(varargin{1}) && ischar(varargin{2})
        n=varargin{1};
        mess=varargin{2};
    else
        disp('WARNING: Check arguments to bigtoc. Function call ignored.')
    end
end

% Perform function
t_tmp=bigtictoc('toc',n);
if nargout==0
    if ~isempty(mess); disp(mess); end;
    disp(['Elapsed time is ',num2str(t_tmp(1)),' seconds'])
    disp(['    CPU time is ',num2str(t_tmp(2)),' seconds'])
else
    t=t_tmp;
end
