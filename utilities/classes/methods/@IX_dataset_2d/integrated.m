function wout = integrated (win, varargin)
% Integrate an IX_dataset_2d object or array of IX_dataset_2d objects along the x and y axes

if numel(win)==0, error('Empty object to integrate'), end
if nargin==1, wout=win; return, end     % benign return if no arguments

integrate_data=true;
point_integration_default=true;
iax=[1,2];                  % axes to integrate over
isdescriptor=true;          % accept only rebin descriptor

[wout,ok,mess] = rebin_IX_dataset_nd (win,...
                     integrate_data, point_integration_default, iax, isdescriptor, varargin{:});
if ~ok, error(mess), end

% Squeeze object
wout=squeeze_IX_dataset_nd(wout,iax);
