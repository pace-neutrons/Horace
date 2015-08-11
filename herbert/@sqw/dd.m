function [figureHandle, axesHandle, plotHandle] = dd(w,varargin)
% Draws a plot of markers, error bars and lines of a 1D sqw object or array of objects
%
%   >> dd(w)
%   >> dd(w,xlo,xhi)
%   >> dd(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dd(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dd(w,...) 


[ok,mess]=dimensions_match(w,1);
if ~ok, error(mess), end

% Check input arguments
nam=get_global_var('horace_plot','name_oned');
opt=struct('newplot',true,'default_name',nam,'lims_type','xy');
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = dd(IX_dataset_1d(w), args{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
