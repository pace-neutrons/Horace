function [figureHandle, axesHandle, plotHandle] = plot(w,varargin)
% Draw an area plot of a d2d dataset or array of datasets
%
%   >> plot(w)
%
% Equivalent to:
%   >> da(w)

[figureHandle_, axesHandle_, plotHandle_] = plot(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
