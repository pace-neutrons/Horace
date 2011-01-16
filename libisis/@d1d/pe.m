function [figureHandle, axesHandle, plotHandle] = pe(win,varargin)
% Overplot errorbars for a 1d dataset on an existing figure.
%
% Optional inputs:
%   >> pe(win)
%   >> pe(win,'color','red')
%
% See help for libisis\pe for more details of further options

% R.A. Ewings 14/10/2008

[figureHandle_, axesHandle_, plotHandle_] = pe(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
