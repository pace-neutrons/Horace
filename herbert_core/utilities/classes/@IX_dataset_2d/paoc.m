function varargout = paoc(w)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> paoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = paoc(w) 

newplot = false;
force_current_axes = true;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, newplot, ...
    force_current_axes, 'area');
