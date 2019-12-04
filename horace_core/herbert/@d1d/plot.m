function [figureHandle, axesHandle, plotHandle] = plot(w,varargin)
% Draws a plot of markers and error bars for a d1d object or array of objects
%
%   >> plot(w)
%   >> plot(w,xlo,xhi)
%   >> plot(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> plot(w,...,'name',fig_name)          % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = plot(w,...) 
%
%
% Synonym for dp(...)

[figureHandle_, axesHandle_, plotHandle_] = plot(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
