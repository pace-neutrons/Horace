function [figureHandle, axesHandle, plotHandle] = pl(win,varargin)
% Overplot line for a d1d object or array of objects on an existing plot
%
%   >> pl(w)
%
% Advanced use:
%   >> pl(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pl(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = pl(sqw(win),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
