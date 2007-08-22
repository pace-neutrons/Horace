function wout = interp_p1(win, varargin)
% Interpolate an d2d or array of d2d along x axis only
%
% The interpolation options are the same as the Matlab built-in routine interpn.
% For further details look at the Matlab help for interpn.
%
% Syntax:
%   >> wout = interp_p1(w,xi)
%   >> wout = interp_p1(w,wref)
%   >> wout = interp_p1(...,method)
%   >> wout = interp_p1(...,method,'extrap')
%
%   w           Input d2d or array of d2d
%
%   xi          Vector that defines the grid points at which interpolated values will be calculated
%                - output will be a point d2d along the x-axis
%               *OR*
%   wref        Another d1d or d2d from which the x values will be taken
%              (in this case must be a single d1d or d2d)
%                - output will be a histogram or point along the x axis according
%                  as the d1d or d2d from which the x  values are taken
%
%   method          'nearest'   Nearest neighbour interpolation
%                   'linear'    Linear interpolation (default)
%                   'spline'    Cubic spline interpolation
%                   'cubic'     
%
%   extrapval   Value given to out-of-range points - NaN or 0 often used
%
% See also:
%   interp, interp_y
%
% See libisis documentation for interp_x for advanced syntax 

wout = dnd_data_op(win, @interp_x, 'd2d' , 2, varargin{:});