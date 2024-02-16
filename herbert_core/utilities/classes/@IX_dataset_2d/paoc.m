function varargout = paoc(w)
% Overplot an area plot of an IX_dataset_2d or array of IX_dataset_2d on the current plot
%
%   >> paoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = paoc(w) 


% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,lims,fig]=genie_figure_parse_plot_args(opt);

% Perform plot
type='area';
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig);


% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end

