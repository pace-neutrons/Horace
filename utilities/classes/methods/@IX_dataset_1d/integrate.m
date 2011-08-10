function wout = integrate (win, varargin)
% Integrate one or more IX_dataset_1d objects between two limits
%
%   >> wout = integrate (win, xmin, xmax)
%   >> wout = integrate (win, [xmin, xmax])
%
%   win         Single or array of IX_dataset_1d datasets to be integrated
%   xmin        Lower integration limit
%   xmax        Upper integration limit
%
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

ndim=1;
rebin_hist_func={@rebin_1d_hist};
integrate_points_func={@integrate_1d_points};

[wout,ok,mess] = integrate_IX_dataset_nd (win, ndim, rebin_hist_func, integrate_points_func, varargin{:},'int');
if ~ok, error(mess), end
