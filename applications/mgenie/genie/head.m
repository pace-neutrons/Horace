function head (varargin)
% List header information for one or more runs to the screen
%
%   >> head                     % header info for currently assigned data source
%   >> head irun                % For given run number
%   >> head irun_lo irun_hi     % For given run number range
%
%   >> head (irun               % Ror given run number
%   >> head (irun_lo,irun_hi)   % For given run number range
%   >> head (irun_array)        % Array of run numbers


% Catch case of no input
if nargin==0
    disp('---------------------------------------------------------------------------')
    head_listing
    disp('---------------------------------------------------------------------------')
    return
end

% Read parameters from either function syntax or command syntax
if isnumeric(varargin{1})
    x1=varargin{1};
elseif ~isempty(varargin{1}) && isstring(varargin{1})
    try
        x1=evalin('caller',varargin{1});
    catch
        error('Check input argument(s)');
    end
    if ~isnumeric(x1)
        error('Check input argument(s)');
    end
else
    error('Check input argument(s)');
end

if nargin==2
    if ~isscalar(x1)
        error('Check first argument is a single run number if a second argument is given')
    else
        if isnumeric(varargin{2}) && isscalar(varargin{2})
            x2=varargin{2};
        elseif ~isempty(varargin{2}) && isstring(varargin{2})
            try
                x2=evalin('caller',varargin{2});
            catch
                error('Check input arguments');
            end
            if ~isnumeric(x2) || ~isscalar(x2)
                error('Check input arguments');
            end
        else
            error('Check input arguments');
        end
        if x1<=x2
            runno=x1:x2;
        else
            runno=x1:-1:x2;
        end
    end
else
    runno=x1;
end

% Print header(s)
for i=1:numel(runno)
    ass(runno(i));
    disp('---------------------------------------------------------------------------')
    head_listing
end
disp('---------------------------------------------------------------------------')


%------------------------------------------------
function head_listing
hdr = genie_get('hdr');
user= genie_get('user');
titl= genie_get('titl');
crpb= genie_get('crpb');
line1 = ['Run ID : ' hdr(1:8) '        User: ' hdr(9:28) '  Inst: ' user{5}];
line2 = ['Protons: ' hdr(73:80) ' uAhrs  Date: ' hdr(53:72) ' to ' crpb{17} ' ' crpb{20}];
disp(line1)
disp(line2)
disp(titl)
