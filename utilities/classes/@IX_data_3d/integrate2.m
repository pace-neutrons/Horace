function wout = integrate2(win, varargin)
% Integrate an IX_dataset_3d object or array of IX_dataset_3d objects along the x-,y- and z-axes
%
%   >> wout = integrate2 (win, descr_x, descr_y, descr_z)
%   >> wout = integrate2 (win, wref)             % reference object to provide output bins
%
%   >> wout = integrate2 (..., 'ave')            % change integration method for axes with point data
%
% Input:
% ------
%   win     Input object or array of objects to be integrated
%   descr   Description of integration bin boundaries (one per axis)
%
%           Integration is performed for each bin defined in the description:
%           * If just one bin is specified, i.e. give just upper an lower limits,
%            then the dataset is integrated over the specified range.
%             The integrate axis disappears i.e. the output object has one less dimension.
%           * If several bins are defined, then the integral is computed for each
%            bin. Essentially, this is rebinning with integration of the contents.
%
%           General syntax for the description of new bin boundaries:
%           - [], ''                Integrate over the full range of the data
%           - 0                     Use current bins to define integration ranges
%           - dx (numeric scalar)   Integration bins centred on zero with constant width dx
%           - [xlo,xhi]             Single integration range
%           - [x1,x2,...xn]         Set of bin boundaries that define integration ranges
%
%           The lower limit can be -Inf and/or the upper limit +Inf, when the
%           corresponding limit is set by the full extent of the data.
%  OR
%   wref    Reference IX_dataset_3d to provide new bins along all three axes
%
%   Point data: for an axis with point data (as opposed to histogram data)
%   'ave'   average the values of the points within each new bin and multiply by bin width
%   'int'   integate the function defined by linear interpolation between the data points (DEFAULT)
%
% Output:
% -------
%   wout    Output object or array of objects
%
% EXAMPLES
%   >> wout = integrate2 (win)    % integrates entire dataset
%   >> wout = integrate2 (win, [],...)
%   >> wout = integrate2 (win, [-Inf,Inf],...)    % equivalent to above
%   >> wout = integrate2 (win, 10,...)
%   >> wout = integrate2 (win, [2000,3000],...)
%   >> wout = integrate2 (win, [2000,Inf],...)
%   >> wout = integrate2 (win, [2000,3000,4000,5000,6000],...)
%
% See also corresponding function integrate which accepts a rebin descriptor
% of form [x1,dx1,x2,dx2,...xn] instead of a set of bin boundaries

wout = integrate_xyz(win,false,1:3,varargin{:});