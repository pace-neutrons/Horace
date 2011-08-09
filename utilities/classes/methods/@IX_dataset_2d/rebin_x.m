function wout = rebin_x(win, varargin)
% Rebin an IX_dataset_2d object or array of IX_dataset_2d objects along the x axis

class_ref=IX_dataset_2d;    % reference class
rebin_hist_func={@rebin_2d_x_hist};
integrate_points_func={@integrate_2d_x_points};
iax=1;                      % axes to integrate over
isdescriptor=true;          % accept only rebin descriptor

[wout,ok,mess] = rebin_IX_dataset_nd (win, class_ref, rebin_hist_func, integrate_points_func, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end
