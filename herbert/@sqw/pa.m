function [figureHandle, axesHandle, plotHandle] = pa(w,varargin)
% Overplot an area plot of a 2D sqw dataset or array of datasets
%
%   >> pa(w)
%
% Advanced use:
%   >> pa(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pa(w,...) 


[ok,mess]=dimensions_match(w,2);
if ~ok, error(mess), end

% Check input arguments
nam=get_global_var('horace_plot','name_area');
opt=struct('newplot',false,'default_name',nam);
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = pa(IX_dataset_2d(w), args{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
