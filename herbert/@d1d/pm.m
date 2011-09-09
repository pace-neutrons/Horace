function [figureHandle, axesHandle, plotHandle] = pm(win,varargin)
% Overplot markers for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pm(win)
%   >> pm(win,'color','red')
%
% See help for libisis\pm for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pm(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
