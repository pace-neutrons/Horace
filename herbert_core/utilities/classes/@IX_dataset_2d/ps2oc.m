function varargout = ps2oc(w, varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d objects
% on the current figure with the possibility of providing a second dataset as
% the source of the image colour scale.
%
%   >> psoc2(w)       % Use error bars to set colour scale
%   >> psoc2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Differs from psoc in that the signal sets the z axis, and the colouring is set by the
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = psoc2(w)

new_axes = false;
force_current_axes = true;
alternate_cdata_ok = true;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_twod(w, alternate_cdata_ok, new_axes, ...
    force_current_axes, 'surface2', varargin{:});
