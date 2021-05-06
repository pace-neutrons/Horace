function [figureHandle, axesHandle, plotHandle] = dh(win,varargin)
% Draws a histogram plot of a d1d object or array of objects
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dh(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dh(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = dh(sqw_old(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
