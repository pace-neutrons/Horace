function [fig_handle, axes_handle, plot_handle] = pdoc(w)
% Overplot markers, error bars and lines for an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> pdoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = pdoc(w) 


% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,ok,mess]=genie_figure_parse_plot_args(opt);
if ~ok, error(mess), end

% Perform plot
[fig_,axes_,plot_]=pdoc(IX_dataset_1d(w));

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
