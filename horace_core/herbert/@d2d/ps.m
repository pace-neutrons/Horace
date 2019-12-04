function [figureHandle, axesHandle, plotHandle] = ps(w,varargin)
% Overplot a surface plot of a d2d dataset or array of datasets
%
%   >> ps(w)
%
% Advanced use:
%   >> ps(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps(w,...)

[figureHandle_, axesHandle_, plotHandle_] = ps(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
