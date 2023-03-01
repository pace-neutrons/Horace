function [fig_handle, axes_handle, plot_handle] = dp(w,varargin)
% Draws a plot of markers and error bars of a spectrum or array of spectra
%
%   >> dp(w)
%   >> dp(w,xlo,xhi)
%   >> dp(w,xlo,xhi,ylo,yhi)
%
% Advanced use:
%   >> dp(w,...,'name',fig_name)        % draw with name = fig_name
%
% Return figure, axes and plot handles:
%   >> [fig_handle, axes_handle, plot_handle] = dp(w,...) 


% Check input arguments
opt=struct('newplot',true,'lims_type','xy');
[~,lims,fig]=genie_figure_parse_plot_args(opt,varargin{:});

% Perform plot
type='p';
[fig_,axes_,plot_]=plot_oned (w,opt.newplot,type,fig,lims{:});


% Output only if requested
if nargout>=1, fig_handle=fig_; end
if nargout>=2, axes_handle=axes_; end
if nargout>=3, plot_handle=plot_; end
