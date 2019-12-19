function [figureHandle, axesHandle, plotHandle] = de(win,varargin)
% Draws a plot of error bars of a d1d object or array of objects
%
%   >> de(w)
%   >> de(w,xlo,xhi)
%   >> de(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> de(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = de(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = de(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
