function [figureHandle, axesHandle, plotHandle] = pl(win,varargin)
% Overplot line through data of a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pl(win)
%   >> pl(win,'color','red')
%
% See help for libisis\pl for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pl(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
