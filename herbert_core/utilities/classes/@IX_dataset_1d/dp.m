function varargout = dp(w,varargin)
% Draws a plot of markers and error bars of an IX_dataset_1d object or array of objects.
%
%   >> dp(w)
%   >> dp(w,xlo,xhi)
%   >> dp(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dp(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dp(w,...)

new_axes = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'p', varargin{:});
