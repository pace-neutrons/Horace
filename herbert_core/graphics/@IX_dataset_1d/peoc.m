function [fig_handle, axes_handle, plot_handle] = peoc(w)
% Overplot error bars for a spectrum or array of spectra on the current plot
%
%   >> peoc(w)
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = peoc(w) 


% Check input arguments
opt=struct('newplot',false,'over_curr',true);
[args,lims,fig]=genie_figure_parse_plot_args(opt);

% Perform plot
type='e';
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig);

% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end