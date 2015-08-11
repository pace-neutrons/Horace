function [figureHandle, axesHandle, plotHandle] = ploc(w)
% Overplot line for a 1D sqw object or array of objects on the current plot
%
%   >> ploc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ploc(w) 


[ok,mess]=dimensions_match(w,1);
if ~ok, error(mess), end

% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,ok,mess]=genie_figure_parse_plot_args(opt);
if ~ok, error(mess), end

% Perform plot
[figureHandle_, axesHandle_, plotHandle_] = ploc(IX_dataset_1d(w));

% Output only if requested
if nargout>=1, figureHandle=figureHandle_; end
if nargout>=2, axesHandle=axesHandle_; end
if nargout>=3, plotHandle=plotHandle_; end
