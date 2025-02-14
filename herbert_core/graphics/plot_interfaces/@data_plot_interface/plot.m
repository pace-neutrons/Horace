function varargout = plot(w,varargin)
% Plot 1D, 2D or 3D object or array of objects
%
%   >> plot(w)
%   >> plot(w, xlo, xhi)                    % if 1D, 2D or 3D
%   >> plot(w, xlo, xhi, ylo, yhi)          % if 2D or 3D
%   >> plot(w, xlo, xhi, ylo, yhi, zlo,zhi) % if 3D
%
% Advanced use:
%   >> plot(w,..., 'name', fig_name)        % plot with figure name = fig_name
% or
%   >> plot(w,..., 'axes', axes_handle)     % plot on the figure with the given
%                                           % figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = plot(w, ...)
%
%
% Equivalent to:
%   >> dp(w)                % 1D dataset
%   >> dp(w, ...)
%
%   >> da(w)                % 2D dataset
%   >> da(w, ...)
%
%   >> sliceomatic(w)       % 3D dataset
%   >> sliceomatic(w, ...)


nd=w(1).dimensions();

varargout = cell(1, nargout);   % output only if requested
switch nd
    case 1
        [varargout{:}] = dp(w, varargin{:});
    case 2
        [varargout{:}] = da(w, varargin{:});
    case 3
        [varargout{:}] = sliceomatic(w, varargin{:});
    otherwise
        error('HORACE:data_plot_interface:runtime_error', ...
            'Can only plot one, two or three-dimensional objects')
end
