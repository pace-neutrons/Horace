function wout = integrate (win, varargin)
% Integrate an IX_dataset_1d object or array of IX_dataset_1d objects along the x-axis

if numel(win)==0, error('Empty object to integrate'), end
% if nargin==1, wout=win; return, end     % benign return if no arguments

integrate_data=true;
point_integration_default=true;
iax=1;                      % axes to integrate over
isdescriptor=false;         % accept only new bin boundaries

[wout,ok,mess] = rebin_IX_dataset_nd (win,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end

% Squeeze object
wout=squeeze_IX_dataset_nd(wout,iax);
