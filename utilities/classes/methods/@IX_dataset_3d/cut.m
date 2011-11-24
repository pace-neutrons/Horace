function wout = cut(win, varargin)
% Cut an IX_dataset_3d object or array of IX_dataset_3d objects along the x,y and z axes

if numel(win)==0, error('Empty object to cut'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

rebin_hist_func={@rebin_3d_x_hist,@rebin_3d_y_hist,@rebin_3d_z_hist};
integrate_points_func={@integrate_3d_x_points,@integrate_3d_y_points,@integrate_3d_z_points};
integrate_data=false;
point_integration_default=false;
iax=[1,2,3];                % axes to integrate over
isdescriptor=false;         % accept only new bin boundaries

[wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end

% Squeeze object
wout=squeeze_IX_dataset_nd(wout,iax);
