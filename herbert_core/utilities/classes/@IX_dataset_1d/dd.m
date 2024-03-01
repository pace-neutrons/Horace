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


[fig_,axes_,plot_] = plot_1d_nd_(w,nargout,'d',varargin{:});

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
