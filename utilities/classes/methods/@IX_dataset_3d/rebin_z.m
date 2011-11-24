function wout = rebin_z(win, varargin)
% Rebin an IX_dataset_3d object or array of IX_dataset_3d objects along the z axis

if numel(win)==0, error('Empty object to rebin'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

rebin_hist_func={@rebin_3d_z_hist};
integrate_points_func={@integrate_3d_z_points};
integrate_data=false;
point_integration_default=false;
iax=3;                      % axes to integrate over
isdescriptor=false;         % accept only new bin boundaries

[wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end
