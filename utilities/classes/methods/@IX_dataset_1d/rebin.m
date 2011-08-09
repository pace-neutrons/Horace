function wout = rebin(win, varargin)
% Rebin an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis
%
%   >> wout = rebin(win, xlo, xhi)      % keep data between xlo and xhi, retaining existing bins
%
%	>> wout = rebin(win, xlo, dx, xhi)  % rebin from xlo to xhi in intervals of dx
%
%       e.g. rebin(win,2000,10,3000)    % rebins from 2000 to 3000 in bins of 10
%
%       e.g. rebin(win,5,-0.01,3000)    % rebins from 5 to 3000 with logarithmically
%                                     spaced bins with width equal to 0.01 the lower bin boundary 
%
%   >> wout = rebin(win, [x1,dx1,x2,dx2,x3...]) % one or more regions of different rebinning
%
%       e.g. rebin(win,[2000,10,3000])
%       e.g. rebin(win,[5,-0.01,3000])
%       e.g. rebin(win,[5,-0.01,1000,20,4000,50,20000])
%
%   >> wout = rebin(win,wref)           % rebin win with the bin boundaries of wref
%
% For any datasets of the array win that contain point data the averaging of the points
% can be controlled:
%
%   >> wout = rebin (...)               % default method: point averaging
%   >> wout = rebin (..., 'int')        % trapezoidal integration
%
%
% Note that this function correctly accounts for x_distribution if histogram data.
% Point data is averaged, as it is assumed point data is sampling a function.
% The individual members of the array of output datasets, wout, have the same type as the 
% corresponding input datasets.

% T.G.Perring 3 June 2011 Based on the original mgenie rebin routine, but with
%                         extension to non-distribution histogram datasets, added
%                         trapezoidal integration for point data.


class_ref=IX_dataset_1d;    % reference class
rebin_hist_func={@rebin_1d_hist};
integrate_points_func={@integrate_1d_points};
iax=1;                      % axes to integrate over
isdescriptor=true;          % accept only rebin descriptor

wout = rebin_IX_dataset_nd (win, class_ref, rebin_hist_func, integrate_points_func, iax, isdescriptor, varargin{:});
