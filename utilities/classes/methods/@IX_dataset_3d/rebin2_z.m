function wout = rebin2_z(win, varargin)
% Rebin an IX_dataset_3d object or array of IX_dataset_3d objects along the z-axis
%
%   >> wout = rebin2_z (win, descr)
%   >> wout = rebin2_z (win, descr, 'int')
%   
% Input:
% ------
%   win     Input object or array of objects to be rebinned
%   descr   Description of new bin boundaries 
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Single bin
%           - [x1,x2,...xn]         Set of bin boundaries
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the 
%           corresponding limit is set by the full extent of the data.
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
%   >> wout = rebin2_z (win, [])
%   >> wout = rebin2_z (win, 10)
%   >> wout = rebin2_z (win, [2000,3000])
%   >> wout = rebin2_z (win, [2000,Inf])
%   >> wout = rebin2_z (win, [2000,3000,4000,5000,6000])
%
% See also corresponding function rebin_z which accepts a rebin descriptor
% of form [x1,dx1,x2,dx2,...xn] instead of a set of bin boundaries


if numel(win)==0, error('Empty object to rebin'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

integrate_data=false;
point_integration_default=false;
iax=3;
opt=struct('empty_is_full_range',false,'range_is_one_bin',true,'array_is_descriptor',false,'bin_boundaries',true);

[wout,ok,mess] = rebin_IX_dataset_nd (win, integrate_data, point_integration_default, iax, opt, varargin{:});
if ~ok, error(mess), end
