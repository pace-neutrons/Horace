function [figureHandle, axesHandle, plotHandle] = ploc(win,varargin)
% Overplot line for a d1d object or array of objects on the current plot
%
%   >> ploc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ploc(w) 

[figureHandle_, axesHandle_, plotHandle_] = ploc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
