function [figureHandle, axesHandle, plotHandle] = paoc(w,varargin)
% Overplot an area plot of a d2d dataset or array of datasets on the current figure
%
%   >> pa(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = paoc(w) 

[figureHandle_, axesHandle_, plotHandle_] = paoc(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
