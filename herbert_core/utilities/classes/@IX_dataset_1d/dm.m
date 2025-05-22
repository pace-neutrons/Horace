function varargout = dm(w,varargin)
% Draws a marker plot of an IX_dataset_1d object or array of objects.
%
%   >> dm(w)
%   >> dm(w,xlo,xhi)
%   >> dm(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dm(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dm(w,...) 

new_axes = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'm', varargin{:});
