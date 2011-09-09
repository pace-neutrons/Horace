function [figureHandle, axesHandle, plotHandle] = pdoc(win,varargin)
% Overplot errorbars, markers and lines for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pdoc(win)
%   >> pdoc(win,'color','red')
%
% See help for libisis\pdoc for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pdoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
