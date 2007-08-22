function wout = interp_p2(win,varargin)
% Interpolate an d2d or array of d2d along y axis only
%
% The interpolation options are the same as the Matlab built-in routine interpn.
% For further details look at the Matlab help for interpn.
%
% Syntax:
%   >> wout = interp_p2(w,yi)
%   >> wout = interp_p2(w,wref)
%   >> wout = interp_p2(...,method)
%   >> wout = interp_p2(...,method,'extrap')
%
%   w           Input d2d or array of d2d
%
%   yi          Vector that defines the grid points at which interpolated values will be calculated
%                - output will be a point d2d along the y-axis
%               *OR*
%   wref        Another d1d or d2d from which the y values will be taken
%              (in this case must be a single d1d or d2d)
%                - output will be a histogram or point along the y axis according
%                  as the d1d or d2d from which the y values are taken
%
%   method          'nearest'   Nearest neighbour interpolation
%                   'linear'    Linear interpolation (default)
%                   'spline'    Cubic spline interpolation
%                   'cubic'     
%
%   extrapval   Value given to out-of-range points - NaN or 0 often used
%
% See also:
%   interp, interp_p1
%
% See libisis documentation for interp_y for advanced syntax 

% Check input arguments:
wout = dnd_data_op(win, @interp_y, 'd2d' , 2, varargin{:});