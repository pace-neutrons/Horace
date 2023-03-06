function [fig_handle, axes_handle, plot_handle] = psoc(w)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> ps(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps(w) 


% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,lims,fig]=genie_figure_parse_plot_args(opt);

% Perform plot
type='surface';
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig);


% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
