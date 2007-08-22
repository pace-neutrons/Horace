function wout = interp(win,varargin)
% Interpolate an IXTdataset_2d or array of IXTdataset_2d
%
% The interpolation options are the same as the Matlab built-in routine interpn.
% For further details look at the Matlab help for interpn.
%
% Syntax:
%   >> wout = interp(w,xi,yi)
%   >> wout = interp(w,wref)
%   >> wout = interp(...,method)
%   >> wout = interp(...,method,extrapval)
%
%   w           Input d2d or array of d2d
%
%   xi,yi       Vectors that define the grid points at which interpolated values will be calculated
%                - output will be a point d2d
%               *OR*
%   wref        Another d2d from which the x values will be taken
%              (in this case must be a single d2d)
%                - output will be a histogram or point along the x and y axes according
%                  as the d2d from which the x and y values are taken
%
%   method          'nearest'   Nearest neighbour interpolation
%                   'linear'    Linear interpolation (default)
%                   'spline'    Cubic spline interpolation
%                   'cubic'     
%
%   extrapval   Value given to out-of-range points - NaN or 0 often used
%
% See also:
%   interp_x, interp_y
%
% See libisis documentation for interp for advanced syntax 

% Check input arguments:
wout = dnd_data_op(win, @interp, 'd2d' , 2, varargin{:});