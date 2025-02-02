function varargout = pp(w,varargin)
% Overplot markers and error bars for a spectrum or array of spectra on an existing plot
%
%   >> pp(w)
%
% Advanced use:
%   >> pp(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)

newplot = false;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'p', varargin{:});
