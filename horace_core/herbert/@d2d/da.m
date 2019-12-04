function [figureHandle, axesHandle, plotHandle] = da(w,varargin)
% Draw an area plot fof a d2d dataset or array of datasets
%
%   >> da(w)
%   >> da(w,xlo,xhi)
%   >> da(w,xlo,xhi,ylo,yhi)
%   >> da(w,xlo,xhi,ylo,yhi,zlo,zhi)
%
% Advanced use:
%   >> da(w,...,'name',fig_name)        % Draw with name = fig_name
%
%   >> da(w,...,'-noaspect')            % Do not change aspect ratio
%                                       % according to data axes unit lengths
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = da(w,...) 

[figureHandle_, axesHandle_, plotHandle_] = da(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
