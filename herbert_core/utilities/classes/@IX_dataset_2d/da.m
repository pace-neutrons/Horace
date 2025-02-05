function varargout = da(w, varargin)
% Draw an area plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> da(w)
%   >> da(w,xlo,xhi)
%   >> da(w,xlo,xhi,ylo,yhi)
%   >> da(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> da(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = da(w,...)

newplot = true;
force_current_axes = false;
alternate_cdata_ok = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, newplot, ...
    force_current_axes, 'area', varargin{:});
