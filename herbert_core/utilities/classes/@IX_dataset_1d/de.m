function varargout = de(w,varargin)
% Draws a plot of error bars of a spectrum or array of spectra
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> de(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = de(w,...)

newplot = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'e', varargin{:});
