function varargout = pp(w,varargin)
% Overplot markers and error bars of an IX_dataset_1d object or array of objects on an existing plot.
%
%   >> pp(w)
%
% Advanced use:
%   >> pp(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)

new_axes = false;
force_current_axes = false;

varargout = cell(1, nargout);   % output only if requested
[varargout{:}] = plot_oned(w, new_axes, force_current_axes, 'p', varargin{:});
