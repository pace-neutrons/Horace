function [fig_,axes_,plot_] = overplot_1d_nd_(w,type,varargin)
%overplot_1d_nd_ overplot one or array of 1D datasets on existing plot
%
% if plot does not exist, create one.
%
%

% Check input arguments
opt=struct('newplot',false);
[~,~,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot(s) adding them to the same figure
[fig_,axes_,plot_]=plot_oned (w(1),opt.newplot,type,fig);
n_plots = numel(w);
for i=2:n_plots
    [fig_,axes_,plot_]=plot_oned (w(i),opt.newplot,type,fig_);
end
