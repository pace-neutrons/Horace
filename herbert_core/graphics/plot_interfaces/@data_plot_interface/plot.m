function varargout = plot(w,varargin)
% Plot 1D, 2D or 3D sqw object or array of objects
%
%   >> plot(w)
%   >> plot(w,opt1,opt2,...)    % plot with optional arguments
%
% Equivalent to:
%   >> dp(w)                % 1D dataset
%   >> dp(w,...)
%
%   >> da(w)                % 2D dataset
%   >> da(w,...)
%
%   >> sliceomatic(w)       % 3D dataset
%   >> sliceomatic(w,...)
%
% For details of optional parameters type >> help sqw/dp, >> help sqw/da,
% or >> help sqw/sliceomatic as appropriate


nd=w(1).dimensions();

switch nd
    case 1
        [figureHandle_, axesHandle_, plotHandle_] = dp(w,varargin{:});
    case 2
        [figureHandle_, axesHandle_, plotHandle_] = da(w,varargin{:});
    case 3
        [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,varargin{:});
    otherwise
        error('HORACE:data_plot_interface:runtime_error', ...
            'Can only plot one, two or three-dimensional sqw or dnd objects')
end

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,figureHandle_, axesHandle_, plotHandle_);
end
