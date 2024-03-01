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


[fig_,axes_,plot_] = overplot_1d_nd_(w,'d',varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
