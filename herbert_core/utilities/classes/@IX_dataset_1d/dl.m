function varargout = dl(w,varargin)
% Draws a line plot of a spectrum or array of spectra
%
%   >> dl(w)
%   >> dl(w,xlo,xhi)
%   >> dl(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dl(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dl(w,...) 


[fig_,axes_,plot_] = plot_1d_nd_(w,nargout,'l',varargin{:});

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
