function [figureHandle, axesHandle, plotHandle] = ppoc(win,varargin)
% Overplot errorbars and markers for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> ppoc(win)
%   >> ppoc(win,'color','red')
%
% See help for libisis\ppoc for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = ppoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
