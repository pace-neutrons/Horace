function varargout = pmoc(w)
% Overplot markers of an IX_dataset_1d object or array of objects on the current plot.
%
%   >> pmoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pmoc(w) 

new_axes = false;
force_current_axes = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'm');
