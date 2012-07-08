function [figureHandle, axesHandle, plotHandle] = phoc(win,varargin)
% Overplot histogram for a d1d object or array of objects on the current plot
%
%   >> phoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = phoc(w) 

[figureHandle_, axesHandle_, plotHandle_] = phoc(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
