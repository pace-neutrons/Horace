function varargout = ds(w, varargin)
% Draw a surface plot of an IX_dataset_2d or array of IX_dataset_2d objects.
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> ds(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds(w,...) 

new_axes = true;
force_current_axes = false;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, new_axes, ...
    force_current_axes, 'surface', varargin{:});
