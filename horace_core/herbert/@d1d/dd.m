function [figureHandle, axesHandle, plotHandle] = dd(win,varargin)
% Draws a plot of markers, error bars and lines of a d1d object or array of objects
%
%   >> dd(w)
%   >> dd(w,xlo,xhi)
%   >> dd(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dd(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dd(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = dd(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
