function [figureHandle, axesHandle, plotHandle] = peoc(win,varargin)
% Overplot error bars for a d1d object or array of objects on the current plot
%
%   >> peoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = peoc(w) 

[figureHandle_, axesHandle_, plotHandle_] = peoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
