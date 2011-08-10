function wout = integrate_y (win, varargin)
% Integrate one or more IX_dataset_2d objects along the y-axis between two limits
%
%   >> wout = integrate (win)   % integrate over full range of data
%   >> wout = integrate_y (win, ymin, ymax)
%   >> wout = integrate_y (win, [ymin, ymax])
%
% Input:
% -------
%   win         Single or array of IX_dataset_2d datasets to be integrated
%   ymin        Lower integration limit
%   ymax        Upper integration limit
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
rebin_hist_func={@rebin_2d_y_hist};
integrate_points_func={@integrate_2d_y_points};

[wout,ok,mess] = integrate_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin{:},'int');
if ~ok, error(mess), end
