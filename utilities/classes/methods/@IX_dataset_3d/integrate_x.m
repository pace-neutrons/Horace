function wout = integrate_x (win, varargin)
% Integrate an IX_dataset_3d object or array of IX_dataset_3d objects along the x axis

if numel(win)==0, error('Empty object to integrate'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

rebin_hist_func={@rebin_3d_x_hist};
integrate_points_func={@integrate_3d_x_points};
integrate_data=true;
point_integration_default=true;
iax=1;                      % axes to integrate over
isdescriptor=false;         % accept only new bin boundaries

[wout,ok,mess] = rebin_IX_dataset_nd (win, rebin_hist_func, integrate_points_func,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end

% Squeeze object
wout=squeeze_IX_dataset_nd(wout,iax);
