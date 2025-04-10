function varargout = peoc(w)
% Overplot error bars of an IX_dataset_1d object or array of objects on the
% current plot.
%
%   >> peoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = peoc(w)

new_axes = false;
force_current_axes = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'e');
