function varargout = ploc(w)
% Overplot line for a spectrum or array of spectra on the current plot
%
%   >> ploc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ploc(w) 

newplot = false;
force_current_axes = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'l');
