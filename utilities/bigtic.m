function n_out=bigtic(varargin)
% Start timer for both elapsed time and cpu time. Use with bigtoc
%
%   >> bigtic           % Zero the default timer ('zeroth timer')
%   >> n = bigtic       % get an unused timer number, and zero that timer
%   >> bigtic(n)        % Zero the nth timer (n>0)
%
% To remove timers from memory
%   >> bigtic('clear',n)        % remove timer n
%   >> bigtic('clear','all')    % remove all timers (except default)

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

if nargin==0
    if nargout==0
        bigtictoc('tic')
    else
        n_out=bigtictoc('tic');
    end
elseif nargin==1
    if isnumeric(varargin{1})
        n=varargin{1};
        bigtictoc('tic',n)
    else
        disp('WARNING: Input to bigtic not valid. Function call ignored.')
    end
elseif nargin==2
    if ischar(varargin{1}) && size(varargin{1},1)==1 && strcmpi(strtrim(varargin{1}),'clear')    % row string
        if isnumeric(varargin{2})
            n=varargin{2};
            bigtictoc('clear',n)
        elseif ischar(varargin{1}) && size(varargin{1},1)==1 && strcmpi(strtrim(varargin{1}),'all')
            bigtictoc('clear','all');
        else
            disp('WARNING: Input to bigtic not valid. Function call ignored.')
        end
    else
        disp('WARNING: Input to bigtic not valid. Function call ignored.')
    end
end

