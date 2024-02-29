function varargout = pdoc(w,varargin)
% Overplot markers, error bars and lines for a spectrum or array of spectra on the current plot
%
%   >> pdoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pdoc(w)

[fig_,axes_,plot_] = overplot_only_1d_nd_(w,'d',varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end

