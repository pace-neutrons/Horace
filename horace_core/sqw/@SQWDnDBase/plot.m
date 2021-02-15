function [figureHandle, axesHandle, plotHandle] = plot(w,varargin)
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


[ok,mess,nd]=dimensions_match(w);
if ~ok, error(mess), end
if nd<1 || nd>3
    error('Can only plot one, two or three-dimensional sqw objects')
end

if nd==1
    [figureHandle_, axesHandle_, plotHandle_] = dp(w,varargin{:});
elseif nd==2
    [figureHandle_, axesHandle_, plotHandle_] = da(w,varargin{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = sliceomatic(w,varargin{:});
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
