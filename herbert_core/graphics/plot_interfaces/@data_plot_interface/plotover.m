function varargout = plotover(w,varargin)
% Overplot 1D, 2D or 3D sqw object or array of objects
%
%   >> plotover(w)
%   >> plotover(w,opt1,opt2,...)    % plot with optional arguments
%
% Equivalent to:
%   >> pp(w)                % 1D dataset
%   >> pp(w,...)
%
%   >> pa(w)                % 2D dataset
%   >> pa(w,...)
%
% For details of optional parameters type >> help sqw/pp, >> help sqw/pa,
% as appropriate


nd=w(1).dimensions();
if nd<1 || nd>2
    error('HORACE:SqwDnDPlotInterface:runtime_error', ...
        'Can overplot plot one or two-dimensional sqw or dnd objects')
end

if nd==1
    [figureHandle_, axesHandle_, plotHandle_] = pp(w,varargin{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = pa(w,varargin{:});
end

% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,figureHandle_, axesHandle_, plotHandle_);
end
