function varargout = dd(w,varargin)
% Draws a plot of markers, error bars and lines of an IX_dataset_1d object or array of objects.
%
%   >> dd(w)
%   >> dd(w,xlo,xhi)
%   >> dd(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dd(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dd(w,...)

new_axes = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'd', varargin{:});
