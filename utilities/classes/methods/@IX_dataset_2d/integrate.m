function wout = integrate (win, varargin)
% Integrate one or more IX_dataset_2d objects along the x and y axes between two limits
%
%   >> wout = integrate (win)   % integrate over full range of data
%   >> wout = integrate (win, xmin, xmax, ymin, ymax)
%   >> wout = integrate (win, [xmin, xmax, ymin, ymax])
%   >> wout = integrate (win, [xmin, xmax], [ymin, ymax])
%
% Input:
% -------
%   win         Single or array of IX_dataset_2d datasets to be integrated
%   xmin        Lower integration limit along x-axis
%   xmax        Upper integration limit along x-axis
%   ymin        Lower integration limit along y-axis
%   ymax        Upper integration limit along y-axis
%
% Output:
% -------
%   wout        Ouput:
%               - if single input dataset, then structure with two fields
%                   wout.val    integral
%                   wout.err    standard deviation
%               - if array of input dataset
%                   wout        single IX_dataset_1d of integrals
%
% Function uses histogram integration for histogram data, and
% trapezoidal integration for point data.

if numel(win)==0, error('Empty object to integrate'), end

ndim=2;
rebin_hist_func={@rebin_2d_x_hist,@rebin_2d_y_hist};
integrate_points_func={@integrate_2d_x_points,@integrate_2d_y_points};

[wout,ok,mess] = integrate_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin{:},'int');
if ~ok, error(mess), end
