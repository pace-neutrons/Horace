function [figureHandle, axesHandle, plotHandle] = ds(w,varargin)
% Draw a surface plot of a d2d dataset or array of datasets
%
%   >> ds(w)
%   >> ds(w,xlo,xhi)
%   >> ds(w,xlo,xhi,ylo,yhi)
%   >> ds(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> ds(w,...,'name',fig_name)        % Draw with name = fig_name
%
%   >> ds(w,...,'-noaspect')            % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ds(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = ds(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
