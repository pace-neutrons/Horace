function wout = rebind(win, varargin)
% Rebin an IX_dataset_2d object or array of IX_dataset_2d objects along the x and y axes

if numel(win)==0, error('Empty object to rebin'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

rebin_hist_func={@rebin_2d_x_hist,@rebin_2d_y_hist};
integrate_points_func={@integrate_2d_x_points,@integrate_2d_y_points};
iax=[1,2];                  % axes to integrate over
isdescriptor=true;          % accept only rebin descriptor

[wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end
