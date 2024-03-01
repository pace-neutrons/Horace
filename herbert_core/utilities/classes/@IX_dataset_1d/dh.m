function varargout = dh(w,varargin)
% Draws a histogram plot of a spectrum or array of spectra
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dh(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dh(w,...) 


[fig_,axes_,plot_] = plot_1d_nd_(w,nargout,'h',varargin{:});

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
