function varargout = pa(w, varargin)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d objects.
%
%   >> pa(w)
%
% Advanced use:
%   >> pa(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pa(w,...) 

new_axes = false;
force_current_axes = false;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, new_axes, ...
    force_current_axes, 'area', varargin{:});
