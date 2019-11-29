function wout = cut_xyz(win, dir,varargin)
% Make a cut from an IX_dataset object or array of IX_dataset objects along
% specified axis direction or number of axis .
%
%   >> wout = cut_x (win, descr)
%   >> wout = cut_x (win, wref)           % reference object to provide output bins
%
%   >> wout = cut_x (..., 'int')          % change averaging method for point data
%
% Input:
% ------
%   win     Input object or array of objects to be cut
%   descr   Description of new bin boundaries
%           - [], '' or zero:       Leave bins unchanged
%           - dx (numeric scalar)   New bins centred on zero with constant width dx
%           - [xlo,xhi]             Single bin
%           - [xlo,dx,xhi]          Set of equal width bins centred at xlo, xlo+dx, xlo+2*dx,...
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset to provide new bins along specified axes
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin (DEFAULT)
%   'int'   integrate the function defined by linear interpolation between the data points
%
% Output:
% -------
%   wout    Output object or array of objects
%           If just one bin was specified along an axis, i.e. gave just upper and
%          lower limits, then the output object has dimension reduced by one.
%
% EXAMPLES
%   >> wout = cut_xyz (win,dir, [])
%   >> wout = cut_xyz (win,dir, [-Inf,Inf])    % equivalent to above
%   >> wout = cut_xyz(win,dir,10)
%   >> wout = cut_xyz(win,dir,[2000,3000])
%   >> wout = cut_xyz(win,dir,[2000,Inf])
%   >> wout = cut_xyz(win,dir,[2000,3000,4000,5000,6000])
%
% Cut is similar to rebin, except that any axes that have just one bin reduce the
% dimensionality of the output object by one, and the rebin descriptor defines
% bin centres, not bin boundaries.

if numel(win)==0, error('Empty object to cut'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

ndims = win.ndim;

if max(dir)>ndims
    error('IX_dataset:invalid_argument',...
        'Attempting to cut from %dD object along %d direction', dimensions(win),dir)
end
if any(dir>ndims)
    error('IX_dataset:invalid_argument',...
        'Attempting to cut  %dD object along %d direction(s)', ndims,dir(dir>ndims))    
end


integrate_data=false;
point_integration_default=false;
iax=dir;

opt=struct('empty_is_full_range',false,'range_is_one_bin',true,'array_is_descriptor',true,'bin_boundaries',false);

[wout,ok,mess] = rebin_IX_dataset_(win, integrate_data, point_integration_default, iax, opt, varargin{:});
% Squeeze object(s)
wout=wout.squeeze_IX_dataset(iax);
if isa(wout,'IX_dataset')
    wout = wout.isvalid();
end

if ~ok, error(mess), end

