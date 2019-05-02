function [figureHandle, axesHandle, plotHandle] = ps2oc(w,varargin)
% Overplot a surface plot of a d2d object or array of d2d objects on the current figure
% The colour scale comes from a second source
%
%   >> ps2oc(w)     % Use error bars to set colour scale
%   >> ps2oc(w,wc)  % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Differs from ps in that the signal sets the z axis, and the colouring is set by the 
% error bars, or another object. This enable a function of three variables to be plotted
% (e.g. dispersion relation where the 'signal' array hold the energy
% and the error array hold the spectral weight).
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2oc(w) 

if ~isa(w,'d2d')
    error('Object to plot must be a d2d object or array of objects')
end

[figureHandle_, axesHandle_, plotHandle_] = ps2oc(sqw(w),varargin{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
