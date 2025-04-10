function varargout = paoc(w)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d objects.
% on the current plot.
%
%   >> paoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = paoc(w) 

new_axes = false;
force_current_axes = true;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, new_axes, ...
    force_current_axes, 'area');
