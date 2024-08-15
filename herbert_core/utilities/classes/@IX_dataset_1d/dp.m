function varargout = dp(w,varargin)
% Draws a plot of markers and error bars of a spectrum or array of spectra
%
%   >> dp(w)
%   >> dp(w,xlo,xhi)
%   >> dp(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dp(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dp(w,...)


[fig_,axes_,plot_] = plot_1d_nd_(w,'p',varargin{:});

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
