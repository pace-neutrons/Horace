function varargout = ps(w,varargin)
% Overplot a surface plot of an IX_dataset_2d or array of IX_dataset_2d
%
%   >> ps(w)
%
% Advanced use:
%   >> ps(w,'name',fig_name)        % overplot on figure with name = fig_name
%                                   % or figure with given figure number or handle
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = ps(w,...) 


% Check input arguments
opt=struct('newplot',false);
[args,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});


% Perform plot
type='surface';
[fig_,axes_,plot_]=plot_twod (w,opt.newplot,type,fig);


% Output only if requested
if nargout>0
    varargout = data_plot_interface.set_argout(nargout,fig_,axes_,plot_);
end
