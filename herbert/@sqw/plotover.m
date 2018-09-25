function [figureHandle, axesHandle, plotHandle] = plotover(w,varargin)
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


[ok,mess,nd]=dimensions_match(w);
if ~ok, error(mess), end
if nd<1 || nd>2
    error('Can only plot one or two-dimensional sqw objects')
end

if nd==1
    [figureHandle_, axesHandle_, plotHandle_] = dp(w,varargin{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = da(w,varargin{:});
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
