function wout = interp(win, varargin)
% Interpolate an d1d or array of d1d
%
% The interpolation options are the same as the Matlab built-in routine interp1.
% For further details look at the Matlab help for interp1.
%
% Syntax:
%   >> wout = interp(w,xi)
%   >> wout = interp(w,wref)
%   >> wout = interp(...,method)
%   >> wout = interp(...,method,'extrap')
%   >> wout = interp(...,method,extrapval)
%
%   w           Input d1d or array of d1d
%
%   xi          Values at which interpolated values will be calculated
%                - output will be a point d1d
%               *OR*
%   wref        Another d1d from which the x values will be taken
%              (in this case must be a single d1d)
%                - output will be a histogram or point d1d according
%                  as the type from which the x values are taken
%
%   method          'nearest'   Nearest neighbour interpolation
%                   'linear'    Linear interpolation (default)
%                   'spline'    Cubic spline interpolation
%                   'pchip'     Piecewise cubic Hermite interpolation
%                   'cubic'     (Same as 'pchip')
%                   'v5cubic'   Cubic interpolation used in MATLAB 5
%
%   'extrap'    Extrapolates using the specified method. If not given, then
%               the Matlab default behaviour is followed:
%                   no extrapolation: 'nearest', 'linear', 'v5cubic'
%                   extrapolation:    'spline', 'pchip', 'cubic'
%
%   extrapval   Value given to out-of-range points - NaN or 0 often used

% Check input arguments:
wout = dnd_data_op(win, @interp, 'd1d' , 1, varargin{:});
