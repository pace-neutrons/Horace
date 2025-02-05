function varargout = psoc(w)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> psoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps(w) 

newplot = false;
force_current_axes = true;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, newplot, ...
    force_current_axes, 'surface');
