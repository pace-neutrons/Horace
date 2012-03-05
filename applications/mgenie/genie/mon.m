function w = mon (varargin)
% Read monitor spectrum from current data source.
%
%   >> m = mon (imon)
%   >> m = mon (imon, periods)
%   >> m = 


%
% Optionally give the period
% number and request that time-of-flight parameters are not returned. [Not
% requesting time-of-flight parameters speeds up access, and if units
% conversion is not needed can be ignored.]
%
% Syntax:
%   >> m = mon(imon [,iperiod] [,'none'])
% e.g.
%   >> m2 = mon(2)          % get monitor 2
%   >> m2 = mon(2,17)       % get monitor 2 for 17th period
%   >> m2 = mon(2,[1,5,9])  % return an array of spectra for periods 1,5 and 9
%   >> m2 = mon(2,'none')
%   >> m2 = mon(2,17,'none')
%

% Check there is a valid number of input arguments
if (nargin==0)
    error ('Must have at least one argument')
elseif (nargin>3)
    error ('Too many arguments')
end

% Strip off the averaging mode, if present
if ischar(varargin{nargin})
    average_mode = lower(varargin{nargin});
    nargs = nargin - 1;
else
    average_mode = '';
    nargs = nargin;
end

if nargs>=1 
    imon = varargin{1};
end
if nargs>=2 
    period = varargin{2};
else
    period = 1;
end

% Check monitor number:
nmon = genie_get('nmon');
if (~isa(imon,'double'))
    error ('Check monitor number is numeric')
elseif (imon < 1 || imon > nmon)
    error ('Invalid monitor number')
end

% Check periods if given:
if nargs>1
    nperiod = double(genie_get('nper'));
    if (~isa(period,'double'))
        error ('Check period number is numeric')
    elseif (max(period) > nperiod || min(period) < 1)
        error (['Period number(s) must lie in range 1 - ',num2str(nperiod)])
    end
end

% Get monitor spectrum:
mdet = genie_get('mdet');
spec_list = genie_get('spec');
if nargs==1
    w = spec(double(spec_list(mdet(imon))),'none');
else
    w = spec(double(spec_list(mdet(imon))),'period',period,'none');    % MATLAB doesn't understand integers, so must convert to double
end
if ~strcmpi(average_mode,'none')  % Get detector parameters if do not specify otherwise
    [delta_raw, twotheta_raw, azimuth_raw, x2_raw] = get_secondary;
    delta = delta_raw(mdet(imon));
    x1 = get_primary;
    x2 = x2_raw(mdet(imon));
    twotheta = twotheta_raw(mdet(imon));
    azimuth = azimuth_raw(mdet(imon));
    par = tofpar(0,delta,x1,x2,twotheta,azimuth,0);
    for iw=1:length(period)
        w(iw).tofpar = par;     % monitors by definition assumed to be elastic
    end
end
