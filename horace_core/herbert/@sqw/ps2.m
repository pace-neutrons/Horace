function [figureHandle, axesHandle, plotHandle] = ps2(w,varargin)
% Overplot a surface plot of a 2D sqw dataset or array of datasets
%
%   >> ps2(w)       % Use error bars to set colour scale
%   >> ps2(w,wc)    % Signal in wc sets colour scale
%                   %   wc can be any object with a signal array with same
%                   %  size as w, e.g. sqw object, IX_dataset_2d object, or
%                   %  a numeric array.
%                   %   - If w is an array of objects, then wc must contain
%                   %     the same number of objects.
%                   %   - If wc is a numeric array then w must be a scalar
%                   %     object.
%
% Differs from ds in that the signal sets the z axis, and the colouring is
% set by the error bars, or by another object. This enables two related 
% functions to be plotted (e.g. dispersion relation where the 'signal'
% array holds the energy and the error array holds the spectral weight).
%
% Advanced use:
%   >> ps(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps2(w,...) 


% Check input arguments (must allow for the two cases of one or two plotting input arguments)
if ~isa(w,'sqw')
    error('Object to plot must be an sqw object or array of objects')
end

[ok,mess]=dimensions_match(w,2);
if ~ok, error(mess), end

nam=get_global_var('horace_plot','name_surface');
opt=struct('newplot',false,'default_name',nam);
[args,ok,mess,nw]=genie_figure_parse_plot_args2(opt,w,varargin{:});
if ~ok, error(mess), end
if nw==2
    [figureHandle_, axesHandle_, plotHandle_] = ps2(IX_dataset_2d(w), IX_dataset_2d(varargin{1}), args{:});
else
    [figureHandle_, axesHandle_, plotHandle_] = ps2(IX_dataset_2d(w), args{:});
end

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
