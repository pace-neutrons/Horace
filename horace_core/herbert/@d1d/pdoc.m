function [figureHandle, axesHandle, plotHandle] = pdoc(win,varargin)
% Overplot markers, error bars and lines for a d1d object or array of objects on the current plot
%
%   >> pdoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pdoc(w) 

[figureHandle_, axesHandle_, plotHandle_] = pdoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
