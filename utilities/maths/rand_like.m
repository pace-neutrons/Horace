function R=rand_like(varargin)
% Create random-like array, but independent of Matlab intrinsic functions
%
%   >> R = rand_like                % scalar return
%   >> R = rand_like(2)             % 2x2 square array return
%   >> R = rand_like(2,4)           % 2x4 array return
%   >> R = rand_like(2,4,5)         % 3D sarray
%   >> R = rand_like([2,4,5])       % equivalent to above
%
% To initialise with a particular seed:
%   >> rand_like('start')           % sets seed to default initial value
%   >> rand_like('start',val)       % val is any number
%
% To retrieve the current seed value:
%   >> val = rand_like('fetch')
%
% Note: the first call to rand_like without the 'start' option in the Matlab
% session is equivalent to rand_like(...,'start',0)
%
% Will always generate the same numbers.
%
% Is much slower (x100?) than Matlab rand if called for scalar output.

persistent start_saved

% Find seed, or set if 'start' option given
start_default=sin(sqrt(14837.2*exp(0.1241)));
if nargin==0 || ~ischar(varargin{1})
    if isempty(start_saved)
        start=start_default;
    else
        start=start_saved;
    end
elseif strcmpi(varargin{1},'start')
    if nargin==2
        if isnumeric(varargin{2}) && isscalar(varargin{2})
            start_saved=mod(1e5*cos(1e4*(start_default+2*start_default*sqrt(3.96664/pi^1.002344)*varargin{end})),1);
        else
            error('Seed must be numeric scalar')
        end
    elseif nargin==1
        start_saved=start_default;
    else
        error('Seed must be numeric scalar')
    end
    return
elseif strcmpi(varargin{1},'fetch')
    if isempty(start_saved)
        start_saved=start_default;
    end
    R=start_saved;
    return
else
    error('Check input argument(s)')
end

% Get output array size
if numel(varargin)==1
    sz=varargin{1};
    if isscalar(sz)
        sz=sz*[1,1];
    end
elseif numel(varargin)>1
    sz=cell2mat(varargin);
else
    sz=[1,1];
end

% Create array
nv=prod(sz);
if nv>0
    x0=(pi/3)*(17/19)-exp(1)/3; % a number near but not equal to zero
    x=x0+(1:nv)*((1-2*x0)/nv);  % array runs from x0 < x <= 1-x0, equally spaced by approx 1/nv
    scale=sqrt(pi/exp(13.1/17.2034259)); % a number near unity that nobody would ever guess
    R=reshape(mod(1e5*cos((1e4*scale*nv)*(x+start/nv)),1),sz);    % roughly 1e4 to 2e4 periods between each angle
    start_saved=R(end);     % Store start
else
    R=zeros(sz);
end
