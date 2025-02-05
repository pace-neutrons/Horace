function varargout = ps2(w, varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Advanced use:
%   >> ps2(...,'name',fig_name)     % Overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 

newplot = false;
force_current_axes = false;
alternate_cdata_ok = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, newplot, ...
    force_current_axes, 'surface2', varargin{:});
