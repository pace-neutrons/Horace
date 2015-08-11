function [figureHandle, axesHandle, plotHandle] = dm(win,varargin)
% Draws a marker plot of a d1d object or array of objects
%
%   >> dm(w)
%   >> dm(w,xlo,xhi)
%   >> dm(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dm(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dm(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = dm(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
