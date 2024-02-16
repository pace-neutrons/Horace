function [fig_,axes_,plot_] = plot_1d_nd_(w,nout,type,varargin)
%plot_1d_nd_ Plot one or array of 1D datasets in separate plots
%
%
% check input arguments
%
opt=struct('newplot',true,'lims_type','xy');
[~,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

n_plots = numel(w);
fig_ = cell(n_plots,1);
axes_ = cell(n_plots,1);
plot_ = cell(n_plots,1);

% perform plot
[fig_{1},axes_{1},plot_{1}]=plot_oned (w(1),opt.newplot,type,fig,lims{:});
opt.newplot = false;
for i=2:n_plots
    fig = figure;
    % perform another plot
    [fig_{i},axes_{i},plot_{i}]=plot_oned (w(i),opt.newplot,type,fig,lims{:});
end

% if output requested, combine output in array of graphical objects
if nout>0
    fig_  = [fig_{:}];
    axes_ = [axes_{:}];
    plot_ = [plot_{:}];
end
