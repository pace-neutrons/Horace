function varargout = pd(w,varargin)
% Overplot markers, error bars and lines for a spectrum or array of spectra on an existing plot
%
%   >> pd(w)
%
% Advanced use:
%   >> pd(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pd(w,...) 

newplot = false;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'd', varargin{:});
