function [figureHandle, axesHandle, plotHandle] = psoc(w,varargin)
% Overplot a surface plot of a d2d dataset or array of datasets on the current figure
%
%   >> psoc(w)
%
% Advanced use:
%   >> psoc(w,'name',fig_name)      % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = psoc(w)

[figureHandle_, axesHandle_, plotHandle_] = psoc(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
