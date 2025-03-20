function varargout = plotover(w,varargin)
% Overplot 1D, 2D or 3D object or array of objects on an existing plot
%
%   >> plotover(w)
%
% Advanced use:
%   >> pp(w, 'name', fig_name)      % overplot on the figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pp(w,...)
%
%
% Equivalent to:
%   >> pp(w)                % 1D dataset
%   >> pp(w,...)
%
%   >> pa(w)                % 2D dataset
%   >> pa(w,...)


nd = w(1).dimensions();

varargout = cell(1, nargout);   % output only if requested
switch nd
    case 1
        [varargout{:}] = pp(w, varargin{:});
    case 2
        [varargout{:}] = pa(w, varargin{:});
    otherwise
        error('HORACE:data_plot_interface:runtime_error', ...
            'Can only overplot one or two-dimensional objects')
end
