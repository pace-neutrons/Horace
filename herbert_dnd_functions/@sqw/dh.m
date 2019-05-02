function [figureHandle, axesHandle, plotHandle] = dh(w,varargin)
% Draws a histogram plot of a 1D sqw object or array of objects
%
%   >> dh(w)
%   >> dh(w,xlo,xhi)
%   >> dh(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dh(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dh(w,...) 


[ok,mess]=dimensions_match(w,1);
if ~ok, error(mess), end

% Check input arguments
nam=get_global_var('horace_plot','name_oned');
opt=struct('newplot',true,'default_name',nam,'lims_type','xy');
[args,ok,mess]=genie_figure_parse_plot_args(opt,varargin{:});
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = dh(IX_dataset_1d(w), args{:});

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
