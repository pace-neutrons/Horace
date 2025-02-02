function varargout = ppoc(w)
% Overplot markers and error bars for a spectrum or array of spectra on the current plot
%
%   >> ppoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ppoc(w)

newplot = false;
force_current_axes = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'p');
