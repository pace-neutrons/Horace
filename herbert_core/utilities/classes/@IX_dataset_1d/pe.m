function varargout= pe(w,varargin)
% Overplot error bars for a spectrum or array of spectra on an existing plot
%
%   >> pe(w)
%
% Advanced use:
%   >> pe(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pe(w,...) 


[fig_,axes_,plot_] = overplot_1d_nd_(w,'e',varargin{:});
% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
