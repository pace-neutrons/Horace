function varargout = dm(w,varargin)
% Draws a marker plot of a spectrum or array of spectra
%
%   >> dm(w)
%   >> dm(w,xlo,xhi)
%   >> dm(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dm(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dm(w,...) 

newplot = true;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, newplot, force_current_axes, 'm', varargin{:});
