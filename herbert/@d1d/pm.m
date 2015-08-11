function [figureHandle, axesHandle, plotHandle] = pm(win,varargin)
% Overplot markers for a d1d object or array of objects on an existing plot
%
%   >> pm(w)
%
% Advanced use:
%   >> pl(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pm(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = pm(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
