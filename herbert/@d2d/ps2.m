function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
% Overplot a surface plot of a d2d object or array of d2d objects, with colour scale from a second source
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   % (d2d object with same array size as w, or a numeric array)
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 

if ~isa(w,'d2d')
    error('Object to plot must be a d2d object or array of objects')
end

if numel(varargin)>0 && (isa(varargin{1},class(w))||(isnumeric(varargin{1})&&rem(numel(varargin),2)==1))
    if isa(varargin{1},class(w))
        [figureHandle_, axesHandle_, plotHandle_] = ps2(sqw(w),sqw(varargin{1}),varargin{2:end});
    else
        [figureHandle_, axesHandle_, plotHandle_] = ps2(sqw(w),varargin{:});
    end
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
