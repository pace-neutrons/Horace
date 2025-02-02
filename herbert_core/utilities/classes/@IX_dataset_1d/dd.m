function varargout = dd(w,varargin)
% Draws a plot of markers, error bars and lines of a spectrum or array of spectra
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

newplot = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'd', varargin{:});
