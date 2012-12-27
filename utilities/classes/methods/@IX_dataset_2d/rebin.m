function wout = rebin(win, varargin)
% Rebin an IX_dataset_2d object or array of IX_dataset_2d objects along the x- and y-axes
%
%   >> wout = rebin (win, descr_x, descr_y)
%   >> wout = rebin (win, wref)             % reference object to provide output bins
%   
%   >> wout = rebin (..., 'int')            % change averaging method for axes with point data
%   
% Input:
% ------
%   win     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries (one per axis)
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Change limits but bin boundaries in between unchanged
%           - [xlo,dx,xhi]          Lower and upper limits xlo and xhi, with intervening bins
%                                       dx>0    constant bins within the range
%                                       dx<0    logarithmic bins within the range
%                                              (if dx1<0, then must have x1>0, dx2<0 then x2>0 ...)
%                                       dx=0    retain existing bins within the range
%           - [x1,dx1,x2,dx2...xn]  Generalisation to multiple contiguous ranges
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset_2d to provide new bins along both axes
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   average of the function defined by linear interpolation between the data points
%
% Output:
% -------
%   wout    Output object or array of objects
%
% EXAMPLES
%   >> wout = rebin (win, [],...)
%   >> wout = rebin (win, 10,...)
%   >> wout = rebin (win, [2000,3000],...)
%   >> wout = rebin (win, [2000,Inf],...)
%   >> wout = rebin (win, [2000,10,3000],...)
%   >> wout = rebin (win, [5,-0.01,3000],...)
%   >> wout = rebin (win, [5,-0.01,1000,20,4000,50,20000],...)
%
% See also corresponding function rebin2 which accepts a set of bin boundaries
% of form [x1,x2,x3,...xn] instead of a rebin descriptor


if numel(win)==0, error('Empty object to rebin'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

integrate_data=false;
point_integration_default=false;
iax=[1,2];
opt=struct('empty_is_full_range',false,'range_is_one_bin',false,'array_is_descriptor',true,'bin_boundaries',true);

[wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, opt, varargin{:});
if ~ok, error(mess), end
