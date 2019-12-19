function [figureHandle, axesHandle, plotHandle] = pmoc(win,varargin)
% Overplot markers for a d1d object or array of objects on the current plot
%
%   >> pmoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pmoc(w) 

[figureHandle_, axesHandle_, plotHandle_] = pmoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
